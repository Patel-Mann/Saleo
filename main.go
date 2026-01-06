package main

import(
	"log"
	"net/http"

	"github.com/patel-mann/saleo/internal/utils"
	"github.com/patel-mann/saleo/internal/handlers"
)

func main(){
	
	utils.InitDB()

	http.HandleFunc("/", handlers.Get_layout)

	http.HandleFunc("/currency", handlers.Get_currency)

	log.Println("Saleo server started on http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
