if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_hlpw_cliente]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_hlpw_cliente]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
/*

        select cli_id,
               cli_nombre   as Nombre,
               cli_codigo   as Codigo
        from cliente 
  
        where (exists (select * from EmpresaCliente where cli_id = cliente.cli_id) or 1 = 1)

  update usuario set us_empxdpto = 1
  select * from usuario where us_nombre like 'ayanelli'

 sp_hlpw_cliente 557,1,'100',-1,1

 sp_hlpw_cliente 574,1,'',0

*/

create procedure sp_hlpw_cliente (
  @@us_id           int,
  @@emp_id          int,
  @@filter           varchar(255)  = '',
  @@check            smallint       = 0
)
as
begin
  set nocount on

  declare @us_empresaex tinyint
  declare @us_EmpXDpto  tinyint

  select @us_empresaex = us_empresaex, @us_EmpXDpto = us_empxdpto from Usuario where us_id = @@us_id

  if @us_empresaex <> 0 begin

    if @@check <> 0 begin

      select  cli_id,
              cli_nombre        as [Nombre],
              cli_codigo         as [Codigo]
  
      from Cliente
  
      where (cli_nombre = @@filter or cli_codigo = @@filter)
        and activo <> 0
        --and (exists (select * from EmpresaCliente where cli_id = cliente.cli_id and emp_id = @@emp_id))
        and (exists (select * from UsuarioEmpresa where cli_id = cliente.cli_id and us_id = @@us_id) or @@us_id = 1)
  
    end else begin
  
        select top 50
               cli_id,
               cli_nombre   as Nombre,
               cli_codigo   as Codigo
        from cliente 
  
        where (cli_codigo like '%'+@@filter+'%' or cli_nombre like '%'+@@filter+'%' or @@filter = '')
          --and (exists (select * from EmpresaCliente where cli_id = cliente.cli_id and emp_id = @@emp_id))
          and (exists (select * from UsuarioEmpresa where cli_id = cliente.cli_id and us_id = @@us_id) or @@us_id = 1)
    end

  end else begin 
    if @us_EmpXDpto <> 0 begin

      if @@check <> 0 begin
      
        select   cli_id,
                cli_nombre        as [Nombre],
                cli_codigo         as [Codigo]
    
        from Cliente
    
        where (cli_nombre = @@filter or cli_codigo = @@filter)
          and activo <> 0
          and (exists (select * from EmpresaCliente where cli_id = cliente.cli_id and emp_id = @@emp_id))
          and (exists (select * from DepartamentoCliente dc inner join UsuarioDepartamento ud on dc.dpto_id = ud.dpto_id
                        where cli_id = cliente.cli_id and us_id = @@us_id
                       ) 
                or @@us_id = 1
               )    
    
      end else begin
    
        select top 50
               cli_id,
               cli_nombre   as Nombre,
               cli_codigo   as Codigo
        from cliente 
  
        where (cli_codigo like '%'+@@filter+'%' or cli_nombre like '%'+@@filter+'%' or @@filter = '')
          and (exists (select * from EmpresaCliente where cli_id = cliente.cli_id and emp_id = @@emp_id))
          and (exists (select * from DepartamentoCliente dc inner join UsuarioDepartamento ud on dc.dpto_id = ud.dpto_id
                        where cli_id = cliente.cli_id and us_id = @@us_id
                       ) 
                or @@us_id = 1
               )    
      end    

    end else begin
  
      if @@check <> 0 begin
      
        select   cli_id,
                cli_nombre        as [Nombre],
                cli_codigo         as [Codigo]
    
        from Cliente
    
        where (cli_nombre = @@filter or cli_codigo = @@filter)
          and activo <> 0
          and (exists (select * from EmpresaCliente where cli_id = cliente.cli_id and emp_id = @@emp_id))
    
      end else begin
    
        select top 50
               cli_id,
               cli_nombre   as Nombre,
               cli_codigo   as Codigo
        from cliente 
  
        where (cli_codigo like '%'+@@filter+'%' or cli_nombre like '%'+@@filter+'%' or @@filter = '')
          and (exists (select * from EmpresaCliente where cli_id = cliente.cli_id and emp_id = @@emp_id))
    
      end    
    end
  end
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

