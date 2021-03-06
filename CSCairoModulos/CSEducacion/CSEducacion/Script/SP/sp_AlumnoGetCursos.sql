SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_AlumnoGetCursos]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_AlumnoGetCursos]
GO

/*

sp_AlumnoGetCursos 7

*/

create procedure sp_AlumnoGetCursos
(
  @@alum_id   int
)
as
begin
  
  select
       cur.cur_id, 
       cur_nombre as Curso, 
       cur_desde as desde, 
       cur_hasta as hasta, 
       mat_nombre as Materias,
       per.prs_apellido  + ', ' + per.prs_nombre as Profesor,
       per2.prs_apellido  + ', ' + per2.prs_nombre as Tutor

  from Curso cur inner join Materia mat on cur.mat_id = mat.mat_id 
                 left join profesor prof on cur.prof_id = prof.prof_id
                 left join persona per  on prof.prs_id = per.prs_id

                 left join cursoitem curi on cur.cur_id = curi.cur_id and alum_id = @@alum_id
                 left join profesor prof2 on curi.prof_id = prof2.prof_id
                 left join persona per2  on prof2.prs_id = per2.prs_id

  
  where exists(select * from CursoItem where cur_id = cur.cur_id and alum_id = @@alum_id)
  
end

go

