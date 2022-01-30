package main

import (
	"github.com/petardenev/k8s-rest-api2redis/user"
	"github.com/go-redis/redis"
	"github.com/labstack/echo"
	"github.com/labstack/gommon/log"
	"os"
	"strconv"
	"time"
)

func main() {
	addr := os.Getenv("API_SERVER_ADDR")
	redisAddr := os.Getenv("REDIS_ADDR")
	redisDB, _ := strconv.Atoi(os.Getenv("REDIS_DB"))

	redisCli := redis.NewClient(&redis.Options{
		Addr:        redisAddr,
		DB:          redisDB,
		DialTimeout: time.Second,
	})

	s := newServer(redisCli)

	s.Logger.Fatal(s.Start(addr))
}

func newServer(redisCli *redis.Client) *echo.Echo {

	userController := user.NewController(
		user.NewRepository(redisCli))

	e := echo.New()
	e.Logger.SetLevel(log.INFO)
	e.GET("/user/:firstname", userController.Get)
	e.POST("/user", userController.Create)

	return e
}
