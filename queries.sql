select id_aluno, nome, bolsa from aluno where cidade = 'Recife' and bolsa > 0.00 order by id_aluno;
--
select id_disc, nome, carga_horaria from disciplina where id_dep = 1 and obrigatoria = 'S' and carga_horaria >= 60 order by carga_horaria desc, id_disc;
--
select id_turma, disciplina.nome as disciplina, professor.nome as professor
from turma
inner join disciplina on disciplina.id_disc = turma.id_disc
inner join professor on professor.id_prof = turma.id_prof
where ano = 2025 and semestre = 1
order by id_turma;
--
select cidade, count(*) as quantidade
from aluno
group by cidade
order by cidade;
--
select id_aluno, id_turma
from matricula
where situacao = 'CURSANDO' and nota is null
order by id_aluno, id_turma;
--
select disciplina.id_disc, disciplina.nome, avg(matricula.nota) as media, min(matricula.nota) as menor, max(matricula.nota) as maior, count(*) as quantidade
from disciplina
inner join turma on turma.id_disc = disciplina.id_disc
inner join matricula on matricula.id_turma = turma.id_turma
where situacao = 'APROVADO'
group by disciplina.id_disc, disciplina.nome
order by disciplina.id_disc;
--
select aluno.id_aluno, aluno.nome, count(matricula.id_aluno) as total_matriculas
from aluno
left join matricula on matricula.id_aluno = aluno.id_aluno
group by aluno.id_aluno, aluno.nome
order by aluno.id_aluno;
--
select id_dep, nome
from departamento
where not exists (
	select 0
	from professor
	where professor.id_dep = departamento.id_dep
)
order by id_dep;
--
select aluno.id_aluno, aluno.nome, coalesce(sum(participacao.horas), 0) as horas_projetos
from aluno
left join participacao on participacao.id_aluno = aluno.id_aluno
group by aluno.id_aluno, aluno.nome
order by aluno.id_aluno;
--
select matricula.id_aluno, turma.id_disc, count(*) as tentativas
from matricula
inner join turma on turma.id_turma = matricula.id_turma
where situacao != 'TRANCADO'
group by matricula.id_aluno, turma.id_disc
having count(*) > 1
order by matricula.id_aluno, turma.id_disc;
--
select aluno.id_aluno, matricula.id_turma, matricula.nota
from aluno
natural join matricula
where matricula.situacao in ('APROVADO', 'REPROVADO')
	and matricula.nota > (
		select avg(matricula.nota)
		from matricula
		where matricula.situacao in ('APROVADO', 'REPROVADO')
		group by aluno.id_aluno
	)
order by aluno.id_aluno, matricula.id_turma;
--
select aluno.id_aluno, aluno.nome
from aluno
where exists (
	select 0
	from matricula
	natural join turma
	where matricula.id_aluno = aluno.id_aluno
		and matricula.situacao = 'APROVADO'
		and turma.ano = 2025
)
order by aluno.id_aluno;
--
select id_aluno
from aluno
where exists (
	select 0
	from turma
	join disciplina on disciplina.id_disc = turma.id_disc
	join matricula on
		matricula.id_turma = turma.id_turma and
		matricula.id_aluno = aluno.id_aluno and
		matricula.situacao <> 'TRANCADO'
	where disciplina.id_disc = 1
)
union
select id_aluno
from aluno
where exists (
	select 0
	from participacao
	where participacao.id_aluno = aluno.id_aluno
)
order by id_aluno;
--
select id_aluno
from matricula
join turma on turma.id_turma = matricula.id_turma
where matricula.situacao <> 'TRANCADO' and turma.id_disc = 2 and turma.ano = 2025
intersect
select id_aluno
from matricula
join turma on turma.id_turma = matricula.id_turma
where matricula.situacao <> 'TRANCADO' and turma.id_disc = 3 and turma.ano = 2025
order by id_aluno;
--
select id_aluno
from aluno
except
select id_aluno
from matricula
natural join turma
where ano = 2025
order by id_aluno;
--
select id_aluno, id_turma, id_disc, nota
from matricula
natural join turma
where nota > (
	select avg(nota)
	from matricula
	where matricula.id_turma = turma.id_turma
)
order by id_aluno, id_turma;
--
select id_aluno, nome
from aluno
where not exists (
	select 0 -- seleciona todas as obrigatorias do departamento 1
	from disciplina
	where obrigatoria = 'S' and id_dep = 1
	and not exists (
		select 0 -- seleciona todas as matriculas da disciplina do aluno com status aprovado
		from matricula
		natural join turma
		where id_aluno = aluno.id_aluno and
		id_disc = disciplina.id_disc
		and situacao = 'APROVADO' -- se existe uma aprovação, retorna conjunto vazio / se não existe aprovação, retorna conjunto não vazio
	) -- se todas disciplinas tem aprovação, retorna conjunto vazio / se não existe aprovação numa disciplina, retorna conjunto não vazio
)
order by id_aluno;
--
with t0 as (
	select id_aluno, id_disc
	from matricula
	natural join turma
	where situacao = 'APROVADO'
)
select id_aluno, nome
from aluno
where id_aluno <> 1 and
not exists (
	select id_disc
	from t0
	where t0.id_aluno = aluno.id_aluno
	except
	select id_disc
	from t0
	where t0.id_aluno = 1
) and
not exists (
	select id_disc
	from t0
	where t0.id_aluno = 1
	except
	select id_disc
	from t0
	where t0.id_aluno = aluno.id_aluno
)
order by id_aluno;
--
select id_aluno, nome
from aluno
where exists (
	select 0
	from pre_requisito
	where id_disc = 5
)
and not exists (
	select 0
	from pre_requisito
	where id_disc = 5
	and not exists (
		select 0
		from matricula
		natural join turma
		where matricula.id_aluno = aluno.id_aluno
		and turma.id_disc = pre_requisito.id_pre
		and situacao = 'APROVADO'
	)
)
and not exists (
	select 0 from
	matricula
	natural join turma
	where turma.id_disc = 5
	and matricula.id_aluno = aluno.id_aluno
	and situacao = 'APROVADO'
)
order by id_aluno;
--
with professor as (select * from professor where salario is not null)
select id_prof, nome, salario
from professor as p1
where salario > some (select salario from professor as p2 where p1.id_dep = p2.id_dep)
order by id_prof;
--
with professor as (select * from professor where salario is not null)
select id_prof, nome, id_dep, salario
from professor as p1
where salario >= all (select salario from professor as p2 where p1.id_dep = p2.id_dep);
--
with t0 as (
	select id_aluno, count(*) as n_matriculas
	from matricula
	natural join turma
	where situacao <> 'TRANCADO' and ano = 2025
	group by id_aluno
), t1 as (
	select id_aluno, count(*) as n_participacoes
	from participacao
	group by id_aluno
)
select aluno.id_aluno,
	nome,
	coalesce(n_matriculas, 0) as n_matriculas,
	coalesce(n_participacoes, 0) as n_participacoes,
	case when (t0.id_aluno is not null and t1.id_aluno is not null)
		then 'AMBOS'
		when (t0.id_aluno is not null) then 'SO_TURMA'
		else 'SO_PROJETO' end as vinculo
from t0
full outer join t1 on t0.id_aluno = t1.id_aluno
join aluno on aluno.id_aluno = coalesce(t0.id_aluno, t1.id_aluno)
order by aluno.id_aluno;
--
with t0 as (
	select disciplina.id_dep, turma.id_turma, avg(nota) as media
	from turma
	join matricula on matricula.id_turma = turma.id_turma
	join disciplina on disciplina.id_disc = turma.id_disc
	where ano = 2025 and situacao in ('APROVADO', 'REPROVADO')
	group by disciplina.id_dep, turma.id_turma
	having count(*) >= 3
)
select x1.id_dep, x1.id_turma, round(x1.media, 2) as media
from t0 as x1
where not exists (
	select 0
	from t0 as x2
	where x1.id_dep = x2.id_dep and x2.media > x1.media
)
order by x1.id_dep, x1.id_turma;
--
(select id_aluno
from aluno
where exists (
	select 0
	from matricula
	natural join turma
	where matricula.id_aluno = aluno.id_aluno and ano = 2024 and situacao = 'APROVADO'
)
intersect
select id_aluno
from aluno
where exists (
	select 0
	from matricula
	natural join turma
	where matricula.id_aluno = aluno.id_aluno and ano = 2025 and situacao <> 'TRANCADO'
))
except
select id_aluno
from aluno
where exists (
	select 0
	from matricula
	natural join turma
	where matricula.id_aluno = aluno.id_aluno and ano = 2025 and situacao = 'REPROVADO'
);
