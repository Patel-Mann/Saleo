package utils

import(
	"os"
	"fmt"
	"log"
	"database/sql"
	
	"github.com/go-sql-driver/mysql"
	"github.com/joho/godotenv"
)

var DB *sql.DB

func InitDB(){
	var err error

	err = godotenv.Load(".env")
  if err != nil {
  	log.Fatal("Error loading .env file")
  }	
  
	cfg := mysql.NewConfig()
  cfg.User = os.Getenv("DBUSER")
  cfg.Passwd = os.Getenv("DBPASS")
  cfg.Net = "tcp"
  cfg.Addr = "127.0.0.1:3306"
  cfg.DBName = "saleo"
	cfg.ParseTime = true
	
	//dsn := "root@tcp(127.0.0.1:3306)/saleo?parseTime=true"
	DB, err = sql.Open("mysql", cfg.FormatDSN())
	if err != nil{
		log.Fatalf("failed to connect to Database: %v", err)
	}

	err = DB.Ping()
	if err != nil{
		log.Fatalf("failed to ping Database: %v", err)
	}
	fmt.Println("Database Connection Successfull")
}
