package models

import(
	//"encoding/json"
	"time"
)

type Currency struct{
	Currency_id		int
	Code					string
	Name					string
	Symbol				string
	Exchange_rate	float32
	Is_base_currency	bool
	Is_active					bool
	Created_at				*time.Time 
	Updated_at				*time.Time 
}

type Unite_Measure struct{
	Uom_id	int
	Code		string
	Name 		string
	Type								string
	Base_unit_id				int
	Conversion_factor 	float32
	Is_active    				bool
	Created_at 					bool
}

