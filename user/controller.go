package user

import (
	"github.com/labstack/echo"
	"net/http"
)

// Controller defines the CRUD handlers for User.
type Controller interface {
	Create(ctx echo.Context) error
	Get(ctx echo.Context) error
}

// NewController returns the default controller implementation.
func NewController(repository Repository) Controller {
	return &controller{
		repository: repository,
		validator:  newValidator(repository),
	}
}

type controller struct {
	repository Repository
	validator  Validator
}

// Create creates a new user.
func (c *controller) Create(ctx echo.Context) error {
	user := &User{}
	if err := ctx.Bind(user); err != nil {
		return err
	}

	validationErrs, err := c.validator.validate(*user)
	if err != nil {
		return err
	}
	if validationErrs != nil {
		return ctx.JSON(http.StatusBadRequest, validationErrs)
	}

	if err := c.repository.Create(user); err != nil {
		return err
	}

	return ctx.String(http.StatusCreated, "")
}

// Get returns a user.
func (c *controller) Get(ctx echo.Context) error {
	name := ctx.Param("name")
	user, err := c.repository.FindByName(name)
	if err != nil {
		return err
	}

	if user == nil {
		return ctx.JSON(http.StatusNotFound, "user not found")
	}

	return ctx.JSON(http.StatusOK, user)
}
