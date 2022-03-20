use nue_profe

select * from mtb_log
select * from mtb_errors

--select * into profe_dat_fil_BORRAR from profe_dat_fil
--select * into profe_dat_dom_BORRAR from profe_dat_dom
--select * into baja_profe_dat_fil_BORRAR from baja_profe_dat_fil
--select * into baja_profe_dat_dom_BORRAR from baja_profe_dat_dom

select count(*) from _familiaresSinTitulares --1604
select count(*) from profe_dat_fil --968554 - 966950
select count(*) from profe_dat_dom --968554 - 966950
select count(*) from baja_profe_dat_fil --1289774 - 1291378
select count(*) from baja_profe_dat_dom --1289774 - 1291378


declare @resultado tinyint
exec mpa_procesarBeneficiariosSinTitular '1420201001',@resultado output
select @resultado

select 968554 - 966950
select 1289774 - 1291378


