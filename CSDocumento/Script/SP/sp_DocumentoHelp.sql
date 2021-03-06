if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_DocumentoHelp]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_DocumentoHelp]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
/*

 sp_documentohelp 1, 1, 0, '',0,0

 sp_DocumentoHelp 2,1,'',-1,0,'doct_id = 1 or doct_id = 7'
 sp_DocumentoHelp 2,1,'',0,0,'doct_id = 1 or doct_id = 7'

  select * from empresa

*/

create procedure sp_DocumentoHelp (
  @@emp_id          int,
  @@us_id           int,
  @@bForAbm         tinyint,
  @@filter           varchar(255)  = '',
  @@check            smallint       = 0,
  @@doc_id          int,
  @@filter2          varchar(5000)  = ''
)
as
begin
  set nocount on

  declare @sqlstmt varchar(5000)
  declare @bFilterXEmpresa tinyint

  if charindex('{emp_id=0}',@@filter2)<>0 begin
          set @@filter2 = replace(@@filter2,'{emp_id=0}','')
          set @bFilterXEmpresa = 0
  end
  else    set @bFilterXEmpresa = 1

  if charindex('emp_id = ',@@filter2)<>0
          set @bFilterXEmpresa = 0


  /*------------------------------------------
  Este codigo es el que se asigna a @permiso. 
  Se asigna en una sola linea para que sea mas rapida la sentencia

  and exists(select * from Permiso 
              where pre_id = Documento.pre_id_list 
                and (
                      us_id = @@us_id
                    or
                      exists(select * from UsuarioRol where us_id = @@us_id and rol_id = Permiso.rol_id)
                    )
            )
  */
  declare @strUsId varchar(10)
  declare @permisos varchar(500)

  set @strUsId  = convert(varchar,@@us_id)
  set @permisos = ' and exists(select * from Permiso  where pre_id = Documento.pre_id_list and (us_id = ' 
                  + @strUsId
                  + ' or exists(select * from UsuarioRol where us_id = '
                  + @strUsId
                  + ' and rol_id = Permiso.rol_id))) '
  /*-----------------------------------------*/


  if @@check <> 0 begin
  
    set @sqlstmt =             'select   doc_id, '
    set @sqlstmt = @sqlstmt + '        doc_nombre      as [Nombre], '
    set @sqlstmt = @sqlstmt + '        doc_codigo       as [Codigo] '

    set @sqlstmt = @sqlstmt + 'from Documento '

    set @sqlstmt = @sqlstmt + 'where (doc_nombre = '''+@@filter+''' or doc_codigo = '''+@@filter+''') '

    if @@doc_id <> 0
      set @sqlstmt = @sqlstmt + '   and (doc_id = ' + convert(varchar(20),@@doc_id) + ') '

    if @@emp_id <> 0 and @bFilterXEmpresa <> 0 and @@bForAbm = 0
      set @sqlstmt = @sqlstmt + '   and (emp_id = ' + convert(varchar(20),@@emp_id) + ') '

    if @@bForAbm = 0 set @sqlstmt = @sqlstmt + '  and activo <> 0 ' 

    if @@filter2 <> '' 
      set @sqlstmt = @sqlstmt + '  and (' + @@filter2 + ')'

  end else begin

      set @sqlstmt =            'select doc_id, '
      set @sqlstmt = @sqlstmt + '       doc_nombre   as Nombre, '
      set @sqlstmt = @sqlstmt + '       doc_codigo   as Codigo '
      set @sqlstmt = @sqlstmt + 'from Documento '

      set @sqlstmt = @sqlstmt + 'where (doc_codigo like ''%'+@@filter+'%'' or doc_nombre like ''%'+@@filter+'%'' or ''' + @@filter + ''' = '''') '

      if @@emp_id <> 0 and @bFilterXEmpresa <> 0 and @@bForAbm = 0
        set @sqlstmt = @sqlstmt + '   and (emp_id = ' + convert(varchar(20),@@emp_id) + ') '

      if @@bForAbm = 0 set @sqlstmt = @sqlstmt + '  and activo <> 0 ' 

      if @@filter2 <> '' 
        set @sqlstmt = @sqlstmt + '  and (' + @@filter2 + ')'

  end    

  if @@bForAbm = 0 set @sqlstmt = @sqlstmt + @permisos

  exec(@sqlstmt)

end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

