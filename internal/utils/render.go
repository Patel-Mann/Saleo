package utils

import(
	"os"
	"log"
	"bytes"
	"net/http"	
	"html/template"
	"path/filepath"
	
	"github.com/joho/godotenv"
)

func Render(w http.ResponseWriter, tmp string, data interface{}){
	err := godotenv.Load(".env")
	if err != nil{
		log.Fatalf("Error loading .env file: %s", err)
	}
	tmp_path := os.Getenv("TEMPLATE_PATH")
	layout := filepath.Join(tmp_path, "layout.html")
	page := filepath.Join(tmp_path, tmp)
	
	tmps, err := template.ParseFiles(layout, page)
	if err != nil{
		http.Error(w, "Template parsing failed:"+err.Error(), http.StatusInternalServerError)
		return
	}

	var buff bytes.Buffer
	err = tmps.ExecuteTemplate(&buff, "layout", data)
	if err != nil{
		http.Error(w, "Template parsing failed:"+err.Error(), http.StatusInternalServerError)
		return
	}
	buff.WriteTo(w)
}
