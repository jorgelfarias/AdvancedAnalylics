---------------------------------------------------------------------------- conhecendo a base
select 
class()
from datalake.brain_reputation_claim
--where numero_da_reclamacao =''



---------------------------------------------------------------------- contagem dos motivos de reclamações e porcentagem acumulada
select 
	motivo ,
	contagem,
	sum(contagem) over(order by contagem desc) as contagem_acumulada,
	porcentagem,
	sum(porcentagem) over (order by contagem desc) as porcentatem_acumulada
from(
select 
	motivo_da_reclamacao as motivo,
	count(numero_da_reclamacao) as contagem,
	count(*) over(partition by motivo_da_reclamacao order by count(*) desc) as contagem_acumulada,
	round(cast(count(*) as double)*100/ sum(count(*)) over(),2) as porcentagem
from datalake.brain_reputation_claim
where seller_id is not null
group by 1
order by 2 desc )
group by 1,2,4


---------------------------------------------------------------------- contagem do plan_type e porcentagem acumulada
select 
	plan_type ,
	contagem,
	sum(contagem) over(order by contagem desc) as contagem_acumulada,
	porcentagem,
	sum(porcentagem) over (order by contagem desc) as porcentatem_acumulada
from(
select 
	plan_type,
	count(numero_da_reclamacao) as contagem,
	count(*) over(partition by plan_type order by count(*) desc) as contagem_acumulada,
	round(cast(count(*) as double)*100/ sum(count(*)) over(),2) as porcentagem
from datalake.brain_reputation_claim
where seller_id is not null
group by 1
order by 2 desc )
group by 1,2,4






--------------------------------------------------------------------------------------- GMV total ou total de registros
select 
--count(*) ,
round(sum(cast(price as double)+ cast(price_discount as double)+ cast(freight_value as double)),2)
from  datalake.brain_reputation_claim

------------------------------------------------------------------------------------ Validando reclamações com título
select 
	date_trunc('month', data_da_reclamacao)
from  datalake.brain_reputation_claim
where motivo_da_reclamacao in ('O produto está com defeito', 'Envio teve algum outro problema', 'Não recebi o produto','Sem estoque')
group by 1
order by 1 asc


select 
	motivo_da_reclamacao ,
	sum(max(contagem)) over(partition by motivo_da_reclamacao order by contagem desc) as contagem_acumulada
from(
select 
	motivo_da_reclamacao,
	count(numero_da_reclamacao)  as contagem
from datalake.brain_reputation_claim 
group by 1
)
group by 1
order by 2 desc 


----------- sku's COM MAIS DE DUAS RECLAMAÇÕES ---------------------------------------------
select
	count(reclamacoes) filter (where reclamacoes = 1) as "mais de duas",
	count(produto) filter (where reclamacoes = 0) as "até duas",
	count(reclamacoes) as reclamacoes	,
	round( cast(count(reclamacoes) filter (where reclamacoes = 1) as double)*100 / count(reclamacoes),2) as "% mais de dois",
	round( cast(count(reclamacoes) filter (where reclamacoes = 0) as double)*100 / count(reclamacoes),2) as "% até dois"
from(
select 
	product_sku as produto ,
	case
		when count(numero_da_reclamacao) >2 then 1
		when count(numero_da_reclamacao) <=2 then 0
	end as reclamacoes
--	count(numero_da_reclamacao)
from datalake.reputacao_reputacao_meli 
where seller_id <>''  
group by 1
--having count(numero_da_reclamacao)>2
order by 2 desc 
)