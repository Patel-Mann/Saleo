package handlers

import(
	"log"
	"net/http"

	"github.com/patel-mann/saleo/internal/utils"
	"github.com/patel-mann/saleo/internal/models"
)

func Get_currency(w http.ResponseWriter, r *http.Request){
 	rows, err := utils.DB.Query("SELECT * FROM currency")
	if err != nil{
		http.Error(w, "Query Error ", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var array []models.Currency
	for rows.Next(){
		var crn models.Currency
		err := rows.Scan(&crn.Currency_id, &crn.Code, &crn.Name, &crn.Symbol, &crn.Exchange_rate, &crn.Is_base_currency, &crn.Is_active, &crn.Created_at, &crn.Updated_at)
		if err != nil {
			log.Println("Scan error:", err)
			continue
		}
	 array = append(array, crn)
	}

	utils.Render(w, "/currency/currency.html", map[string]interface{}{
		"Title":	"Currency",
		"CurrencyList": array,
		})

} 
