package handlers

import(
	"log"
	"net/http"

	"github.com/patel-mann/saleo/internal/utils"
	"github.com/patel-mann/saleo/internal/models"
)

func Get_unit_measure(w http.ResponseWriter, r *http.Request){
 	rows, err := utils.DB.Query("SELECT * FROM unit_of_measure")
	if err != nil{
		http.Error(w, "Query Error ", http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var array []models.Unit_Measure
	for rows.Next(){
		var x models.Unit_Measure
		err := rows.Scan(&x.Uoam_id, &x.Code, &x.Name, &x.Type, &x.Base_unit_id, &x.Conversion_factor, &x.Is_active, &x.Created_at)
		if err != nil {
			log.Println("Scan error:", err)
			continue
		}
	 array = append(array, crn)
	}

	utils.Render(w, "/unit_measure/unitMeasure.html", map[string]interface{}{
		"Title":	"Unit Of Measure",
		"UnitMeasureList": array,
		})

}
