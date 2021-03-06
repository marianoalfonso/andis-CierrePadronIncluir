USE nue_profe
GO
/****** Object:  StoredProcedure [dbo].[mpa_procesarSintys]    Script Date: 10/1/2021 11:05:02 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





create procedure [dbo].[mpa_procesarBeneficiariosSinTitular]
	@id_proceso varchar(30), --motivo de baja + fecha (14yyyymmdd)
	@estadoProceso tinyint output
as

declare @excaja tinyint
declare @tipo tinyint
declare @beneficio int
declare @coparticipe tinyint
declare @parentesco tinyint
declare @nombre nvarchar(30)
declare @dni int

declare @fechaProceso char(8) = convert(char(8),getdate(),112)
declare @resultado tinyint
declare @contador int = 1

begin try
	
	set @estadoProceso = 0

	declare mcr_procesoBeneficiariosSinTitular cursor scroll for
		select clave_excaja,clave_tipo,clave_numero,clave_coparticipe,clave_parentesco,apenom,numero_doc from _familiaresSinTitulares --1604

	open mcr_procesoBeneficiariosSinTitular
	fetch next from mcr_procesoBeneficiariosSinTitular into
		@excaja,@tipo,@beneficio,@coparticipe,@parentesco,@nombre,@dni

	while @@FETCH_STATUS = 0
	begin

		print 'numero de documento: ' + convert(nvarchar,@dni)

		exec mpa_beneficiarioBaja 
			14,	--familiar sin titular activo             
			@excaja,
			@tipo,
			@beneficio,
			@coparticipe,
			@parentesco,
			@resultado output --resultado del proceso: 0: ok, 1:error

		print 'resultado de la baja: ' + convert(char,@resultado)

		exec mpa_writeLog 
			@id_proceso,
			@fechaProceso,
			@excaja,
			@tipo,
			@beneficio,
			@coparticipe,
			@parentesco,
			@nombre,
			@dni,
			@resultado,
			'baja por beneficiario sin titular'

		set @contador = @contador + 1
		print 'contador: ' + convert(nvarchar,@contador)
		fetch next from mcr_procesoBeneficiariosSinTitular into
			@excaja,@tipo,@beneficio,@coparticipe,@parentesco,@nombre,@dni
	end
	commit transaction
	close mcr_procesoBeneficiariosSinTitular
	deallocate mcr_procesoBeneficiariosSinTitular
end try
begin catch
	set @estadoProceso = 1
		close mcr_procesoBeneficiariosSinTitular
		deallocate mcr_procesoBeneficiariosSinTitular

		insert into dbo.mtb_Errors
		values
		  (suser_sname(),
		   error_number(),
		   error_state(),
		   error_severity(),
		   error_line(),
		   error_procedure(),
		   error_message(),
		   getdate());

end catch