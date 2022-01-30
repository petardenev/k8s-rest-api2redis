package user

import (
	"encoding/json"
	"github.com/go-redis/redis"
)

// Repository defines the CRUD functions for User.
type Repository interface {
	FindByName(firstname string) (*User, error)
	Create(user *User) error
}

// NewRepository returns the default repository implementation.
func NewRepository(client *redis.Client) Repository {
	return &repository{
		store: client,
	}
}

type repository struct {
	store *redis.Client
}

// GenerateID returns the redis hash key.
func (c *repository) GenerateID(firstname string) string {
	return "user:" + firstname
}

// FindByName find the user based on firstname, if not found, a nil User is returned.
func (c *repository) FindByName(firstname string) (*User, error) {
	r := c.store.Get(c.GenerateID(firstname))
	redisErr := r.Err()

	if redisErr != nil && redisErr != redis.Nil {
		return nil, redisErr
	}

	if redisErr == redis.Nil {
		return nil, nil
	}

	data, err := r.Bytes()
	if err != nil {
		return nil, err
	}

	user := &User{}
	err = json.Unmarshal(data, user)

	return user, err
}

// Create creates a new user in redis.
func (c *repository) Create(user *User) error {
	b, err := json.Marshal(user)
	if err != nil {
		return err
	}

	return c.store.Set(c.GenerateID(*user.FirstName), string(b), 0).Err()
}
