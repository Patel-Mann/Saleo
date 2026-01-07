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
	http.HandleFunc("/currency/add", handlers.Add_currency)
	http.HandleFunc("/unit_measure/add", handlers.Get_unit_measure)
	log.Println("Saleo server started on http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
