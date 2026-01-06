package handlers

import(
	"net/http"
	"github.com/patel-mann/saleo/internal/utils"
)

func Get_layout(w http.ResponseWriter, r *http.Request){
	utils.Render(w, "/dashboard.html", map[string]interface{}{
		"Title":	"Currency",
		})
} 
