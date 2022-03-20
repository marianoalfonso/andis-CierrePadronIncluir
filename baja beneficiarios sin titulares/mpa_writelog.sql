USE [nue_profe]
GO

/****** Object:  StoredProcedure [dbo].[mpa_writeLog]    Script Date: 10/1/2021 11:27:49 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[mpa_writeLog]
	@id_proceso nvarchar(30),				--idproceso sintys
	@fecha char(8),
	@excaja tinyint,
	@tipo tinyint,
	@beneficio int,
	@coparticipe tinyint,
	@parentesco tinyint,
	@nombre nvarchar(30),
	@dni int,
	@procesado bit,
	@message nvarchar(200)
as

begin try
	begin transaction
	
		insert into mtb_log values
		(
			@id_proceso,
			@fecha,
			@excaja,
			@tipo,
			@beneficio,
			@coparticipe,
			@parentesco,
			@nombre,
			@dni,
			@procesado,
			@message
		)

	commit transaction
end try
begin catch

    rollback transaction

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
GO


