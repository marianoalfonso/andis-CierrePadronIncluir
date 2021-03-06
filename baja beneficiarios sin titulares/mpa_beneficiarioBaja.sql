USE [nue_profe]
GO
/****** Object:  StoredProcedure [dbo].[mpa_beneficiarioBaja]    Script Date: 10/1/2021 10:23:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter procedure [dbo].[mpa_beneficiarioBaja]
	@proceso tinyint,	--codigo de motivo de baja (tabla motivos)
	--@dni int,
	@excaja tinyint,
	@tipo tinyint,
	@beneficio int,
	@coparticipe tinyint,
	@parentesco tinyint,
	@estado_proceso tinyint output	--resultado del proceso: 0: ok, 1:error
as
BEGIN
	declare @err_msg nvarchar(500)
	declare @fecha char(8)
	declare @nombre nvarchar(40)

	begin try
		begin transaction
	
			----busco existencia del registro en el padron
			--select 
			--	apenom
			--from
			--	--sintys.dbo.profe_dat_fil
			--	nue_profe.dbo.profe_dat_fil
			--where 
			--	clave_excaja = @excaja and
			--	clave_tipo = @tipo and
			--	clave_numero = @beneficio and
			--	clave_coparticipe = @coparticipe and
			--	clave_parentesco = @parentesco
		
			--if @@rowcount = 0
			--begin
			--	print 'no encontre el beneficiario'
			--	set @err_msg = '[mpa_beneficiario_baja] no existe el beneficiario (' + convert(nvarchar,@beneficio) + '-' + convert(nvarchar,@coparticipe) + '-' + convert(nvarchar,@parentesco) + ')'
			--	raiserror(@err_msg, 11, 1)
			--end
	
			--insert into sintys.dbo.baja_profe_dat_fil
			insert into nue_profe.dbo.baja_profe_dat_fil
			select
				Clave_ExCaja,Clave_Tipo,Clave_Numero,Clave_Coparticipe,
				Clave_Parentesco,LeyAplicada,ApeNom,Sexo,EstCivil,Tipo_Doc,
				Numero_Doc,Fe_Nac,Incapacidad,FechAlta,
				getdate(),		--fecha de baja
				'sistemas',	--usuario ejecutor de la baja,
				getdate(),		--fechOpc  (analizar el uso de este campo en otras tablas)
				@proceso,	--motivo baja (parametro recibido)
				''			--codigo obra social
			--from sintys.dbo.profe_dat_fil
			from nue_profe.dbo.profe_dat_fil
			where
				clave_excaja = @excaja and
				clave_tipo = @tipo and
				clave_numero = @beneficio and
				clave_coparticipe = @coparticipe and
				clave_parentesco = @parentesco
			if @@rowcount = 0
			begin
				set @err_msg = '[mpa_beneficiario_baja] no se inserto registro en baja_profe_dat_fil (' + convert(nvarchar,@beneficio) + '-' + convert(nvarchar,@coparticipe) + '-' + convert(nvarchar,@parentesco) + ')'
				raiserror(@err_msg, 11, 1)
			end

			--insert into sintys.dbo.baja_profe_dat_dom
			insert into nue_profe.dbo.baja_profe_dat_dom
			select
				Clave_ExCaja,Clave_Tipo,Clave_Numero,
				Clave_Coparticipe,Clave_Parentesco,Dom_Calle,Dom_Nro,
				Dom_Piso,Dom_Dpto,Cod_Pos,Cug_Pcia,Cug_Dpto,Cug_Loc,Nro_Cap,
				getdate()		--fechOpc  (analizar el uso de este campo en otras tablas)
			--from sintys.dbo.profe_dat_dom
			from nue_profe.dbo.profe_dat_dom
			where
				clave_excaja = @excaja and
				clave_tipo = @tipo and
				clave_numero = @beneficio and
				clave_coparticipe = @coparticipe and
				clave_parentesco = @parentesco
			if @@rowcount = 0
			begin
				set @err_msg = '[mpa_beneficiario_baja] no se inserto registro en baja_profe_dat_dom (' + convert(nvarchar,@beneficio) + '-' + convert(nvarchar,@coparticipe) + '-' + convert(nvarchar,@parentesco) + ')'
				raiserror(@err_msg, 11, 1)
			end

			--delete from sintys.dbo.profe_dat_dom
			delete from nue_profe.dbo.profe_dat_dom
			where
				clave_excaja		= @excaja and
				clave_tipo			= @tipo and
				clave_numero		= @beneficio and
				clave_coparticipe	= @coparticipe and
				clave_parentesco	= @parentesco
			if @@rowcount = 0
			begin
				set @err_msg = '[mpa_beneficiario_baja] no pudo borrarse el registro de baja_profe_dat_dom (' + convert(nvarchar,@beneficio) + '-' + convert(nvarchar,@coparticipe) + '-' + convert(nvarchar,@parentesco) + ')'
				raiserror(@err_msg, 11, 1)
			end

			--delete from sintys.dbo.profe_dat_fil
			delete from nue_profe.dbo.profe_dat_fil
			where
				clave_excaja = @excaja and
				clave_tipo = @tipo and
				clave_numero = @beneficio and
				clave_coparticipe = @coparticipe and
				clave_parentesco = @parentesco
			if @@rowcount = 0
			begin
				set @err_msg = '[mpa_beneficiario_baja] no pudo borrarse el registro de baja_profe_dat_fil (' + convert(nvarchar,@beneficio) + '-' + convert(nvarchar,@coparticipe) + '-' + convert(nvarchar,@parentesco) + ')'
				raiserror(@err_msg, 11, 1)
			end
	
		set @estado_proceso = 0	--proceso ok
		commit transaction
	end try
	begin catch
		print 'entre en el catch'
		if @@TRANCOUNT > 0
				rollback transaction
		set @estado_proceso = 1	--error en el proceso
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

		--declare @message varchar(100) = error_message(),
		--		@severity int = error_severity(),
		--		@state smallint = error_state()
 
		--raiserror (@message, @severity, @state)

	end catch
END