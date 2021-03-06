if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_hlpw_proveedor2]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_hlpw_proveedor2]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
/*

        select prov_id,
               prov_nombre   as Nombre,
               prov_codigo   as Codigo
        from Proveedor 
  
        where (exists (select * from EmpresaProveedor where prov_id = Proveedor.prov_id) or 1 = 1)

  select us_empresaex from usuario

 sp_hlpw_proveedor2 1,3,'sony',-1,1

 sp_hlpw_proveedor2 557,1,'',0

*/

create procedure sp_hlpw_proveedor2 (
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

      select  prov_id,
              prov_nombre        as [Nombre],
              prov_codigo         as [Codigo]
  
      from Proveedor
  
      where (prov_nombre = @@filter or prov_codigo = @@filter)
        and activo <> 0
        and (exists (select * from EmpresaProveedor where prov_id = Proveedor.prov_id and emp_id = @@emp_id))
        and (exists (select * from UsuarioEmpresa where prov_id = Proveedor.prov_id and us_id = @@us_id) or @@us_id = 1)
  
    end else begin
  
        select top 50
               prov_id,
               prov_nombre   as Nombre,
               prov_codigo   as Codigo
        from Proveedor 
  
        where (prov_codigo like '%'+@@filter+'%' or prov_nombre like '%'+@@filter+'%' or @@filter = '')
          and (exists (select * from EmpresaProveedor where prov_id = Proveedor.prov_id and emp_id = @@emp_id))
          and (exists (select * from UsuarioEmpresa where prov_id = Proveedor.prov_id and us_id = @@us_id) or @@us_id = 1)
    end

  end else begin

    if @us_EmpXDpto <> 0 begin

      if @@check <> 0 begin
      
        select   prov_id,
                prov_nombre        as [Nombre],
                prov_codigo         as [Codigo]
    
        from Proveedor
    
        where (prov_nombre = @@filter or prov_codigo = @@filter)
          and activo <> 0
          and (exists (select * from EmpresaProveedor where prov_id = Proveedor.prov_id and emp_id = @@emp_id))
          and (
                   exists (select * from DepartamentoProveedor dc inner join UsuarioDepartamento ud 
                                                                  on dc.dpto_id = ud.dpto_id
                           where prov_id = Proveedor.prov_id and us_id = @@us_id
                          ) 
                or exists (select * from DepartamentoProveedor dp inner join Departamento d
                                                               on dp.dpto_id = d.dpto_id
                          where exists (select * from Permiso 
                                        where pre_id = pre_id_vertareas
                                          and (  us_id = @@us_id
                                              or exists (select * from UsuarioRol where rol_id = Permiso.rol_id
                                                                                 and us_id  = @@us_id
                                                        )
                                              )
                                       )
                            and dp.prov_id = Proveedor.prov_id
                         )
                or @@us_id = 1
               )    
    
      end else begin
    
        select top 50
               prov_id,
               prov_nombre   as Nombre,
               prov_codigo   as Codigo
        from Proveedor 
  
        where (prov_codigo like '%'+@@filter+'%' or prov_nombre like '%'+@@filter+'%' or @@filter = '')
          and (exists (select * from EmpresaProveedor where prov_id = Proveedor.prov_id and emp_id = @@emp_id))
          and (
                   exists (select * from DepartamentoProveedor dc inner join UsuarioDepartamento ud 
                                                                  on dc.dpto_id = ud.dpto_id
                           where prov_id = Proveedor.prov_id and us_id = @@us_id
                          ) 
                or exists (select * from DepartamentoProveedor dp inner join Departamento d
                                                               on dp.dpto_id = d.dpto_id
                          where exists (select * from Permiso 
                                        where pre_id = pre_id_vertareas
                                          and (  us_id = @@us_id
                                              or exists (select * from UsuarioRol where rol_id = Permiso.rol_id
                                                                                 and us_id  = @@us_id
                                                         )
                                              )
                                       )
                            and dp.prov_id = Proveedor.prov_id
                         )
                or @@us_id = 1
               )    
      end    

    end else begin

      if @@check <> 0 begin
      
        select   prov_id,
                prov_nombre        as [Nombre],
                prov_codigo         as [Codigo]
    
        from Proveedor
    
        where (prov_nombre = @@filter or prov_codigo = @@filter)
          and activo <> 0
          and (exists (select * from EmpresaProveedor where prov_id = Proveedor.prov_id and emp_id = @@emp_id))
    
      end else begin
    
          select top 50
                 prov_id,
                 prov_nombre   as Nombre,
                 prov_codigo   as Codigo
          from Proveedor 
    
          where (prov_codigo like '%'+@@filter+'%' or prov_nombre like '%'+@@filter+'%' or @@filter = '')
            and (exists (select * from EmpresaProveedor where prov_id = Proveedor.prov_id and emp_id = @@emp_id))
    
      end    
    end
  end
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

