select
	id_seller,
	plan_type,
	freight_ratio,
	faturamento,
	variacao_total ,
	var1 ,
	var2 ,
	var3
from(
select
	id_seller,
	case
		when (var1=0 and var2=0 and var3=0) then 0
		when (var1=0 and var2=0 and var3<>0) then var3
		when (var1=0 and var2<>0 and var3=0) then var2
		when (var1<>0 and var2=0 and var3=0) then var1
		when (var1=0 and var2<>0 and var3<>0) then (var2 * var3)
		when (var1<>0 and var2=0 and var3<>0) then (var1 * var3)
		when (var1<>0 and var2<>0 and var3=0) then (var1 * var2)
		else (var1 * var2 * var3) 
	end as variacao_total,
	var1,
	var2,
	var3,
	plan_type,
	freight_ratio,
	faturamento,
	dias_olist
from(
		select
			id_seller,
			plan_type,
			freight_ratio,
			faturamento,
			dias_olist,
			coalesce ((cast(gmv_day_60 as double) / nullif(gmv_day_30,0)),1) as "var1",
			coalesce ((cast(gmv_day_90 as double) / nullif(gmv_day_60,0)),1) as "var2",
			coalesce ((cast(gmv_day_120 as double) / nullif(gmv_day_90,0)),1) as "var3"
		from DATALAKE.brain_growth_seller_profile
		)
)
--where variacao_total <> 1