class AddSearchableToSchools < ActiveRecord::Migration[6.1]
  def change
    execute "CREATE EXTENSION btree_gin"
    add_index :schools, :close_date, where: "close_date is NULL"
    add_index :schools, :name, using: :gin
    add_index :schools, :postcode, using: :gin
    add_index :schools, :town, using: :gin
  end
end

__END__

irb(main):004:0> SchoolSearch.call(query: "a").analyze
=>
EXPLAIN ANALYZE for: SELECT "schools".* FROM "schools" INNER JOIN (SELECT "schools"."id" AS pg_search_id, (ts_rank((to_tsvector('simple', coalesc
e("schools"."urn"::text, '')) || to_tsvector('simple', coalesce("schools"."name"::text, '')) || to_tsvector('simple', coalesce("schools"."town"::
text, '')) || to_tsvector('simple', coalesce("schools"."postcode"::text, ''))), (to_tsquery('simple', ''' ' || 'a' || ' ''' || ':*')), 0)) AS ran
k FROM "schools" WHERE ((to_tsvector('simple', coalesce("schools"."urn"::text, '')) || to_tsvector('simple', coalesce("schools"."name"::text, '')
) || to_tsvector('simple', coalesce("schools"."town"::text, '')) || to_tsvector('simple', coalesce("schools"."postcode"::text, ''))) @@ (to_tsque
ry('simple', ''' ' || 'a' || ' ''' || ':*')))) AS pg_search_f79e2ecc220dc52eaea688 ON "schools"."id" = pg_search_f79e2ecc220dc52eaea688.pg_search
_id WHERE "schools"."close_date" IS NULL ORDER BY pg_search_f79e2ecc220dc52eaea688.rank DESC, "schools"."id" ASC

                                                QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
 Gather Merge  (cost=29606.58..29641.77 rows=306 width=90) (actual time=244.603..248.447 rows=7667 loops=1)
   Workers Planned: 1
   Workers Launched: 1
   ->  Sort  (cost=28606.57..28607.33 rows=306 width=90) (actual time=241.919..242.225 rows=3834 loops=2)
         Sort Key: (ts_rank((((to_tsvector('simple'::regconfig, COALESCE((schools_1.urn)::text, ''::text)) || to_tsvector('simple'::regconfig, CO
ALESCE((schools_1.name)::text, ''::text))) || to_tsvector('simple'::regconfig, COALESCE((schools_1.town)::text, ''::text))) || to_tsvector('simpl
e'::regconfig, COALESCE((schools_1.postcode)::text, ''::text))), '''a'':*'::tsquery, 0)) DESC, schools.id
         Sort Method: quicksort  Memory: 733kB
         Worker 0:  Sort Method: quicksort  Memory: 710kB
         ->  Nested Loop  (cost=0.29..28593.93 rows=306 width=90) (actual time=0.214..235.947 rows=3834 loops=2)
               ->  Parallel Seq Scan on schools  (cost=0.00..2387.41 rows=15306 width=86) (actual time=0.010..11.852 rows=13642 loops=2)
                     Filter: (close_date IS NULL)
                     Rows Removed by Filter: 10873
               ->  Index Scan using schools_pkey on schools schools_1  (cost=0.29..1.69 rows=1 width=61) (actual time=0.013..0.013 rows=0 loops=2
7283)
                     Index Cond: (id = schools.id)
                     Filter: ((((to_tsvector('simple'::regconfig, COALESCE((urn)::text, ''::text)) || to_tsvector('simple'::regconfig, COALESCE((
name)::text, ''::text))) || to_tsvector('simple'::regconfig, COALESCE((town)::text, ''::text))) || to_tsvector('simple'::regconfig, COALESCE((pos
tcode)::text, ''::text))) @@ '''a'':*'::tsquery)
                     Rows Removed by Filter: 1
 Planning Time: 0.403 ms
 Execution Time: 249.218 ms
(17 rows)

irb(main):005:0> SchoolSearch.call(query: "alper").analyze
=>
EXPLAIN ANALYZE for: SELECT "schools".* FROM "schools" INNER JOIN (SELECT "schools"."id" AS pg_search_id, (ts_rank((to_tsvector('simple', coalesc
e("schools"."urn"::text, '')) || to_tsvector('simple', coalesce("schools"."name"::text, '')) || to_tsvector('simple', coalesce("schools"."town"::
text, '')) || to_tsvector('simple', coalesce("schools"."postcode"::text, ''))), (to_tsquery('simple', ''' ' || 'alper' || ' ''' || ':*')), 0)) AS
 rank FROM "schools" WHERE ((to_tsvector('simple', coalesce("schools"."urn"::text, '')) || to_tsvector('simple', coalesce("schools"."name"::text,
 '')) || to_tsvector('simple', coalesce("schools"."town"::text, '')) || to_tsvector('simple', coalesce("schools"."postcode"::text, ''))) @@ (to_t
squery('simple', ''' ' || 'alper' || ' ''' || ':*')))) AS pg_search_f79e2ecc220dc52eaea688 ON "schools"."id" = pg_search_f79e2ecc220dc52eaea688.p
g_search_id WHERE "schools"."close_date" IS NULL ORDER BY pg_search_f79e2ecc220dc52eaea688.rank DESC, "schools"."id" ASC

                                                  QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
 Gather Merge  (cost=29606.58..29641.77 rows=306 width=90) (actual time=199.228..200.617 rows=1 loops=1)
   Workers Planned: 1
   Workers Launched: 1
   ->  Sort  (cost=28606.57..28607.33 rows=306 width=90) (actual time=196.112..196.113 rows=0 loops=2)
         Sort Key: (ts_rank((((to_tsvector('simple'::regconfig, COALESCE((schools_1.urn)::text, ''::text)) || to_tsvector('simple'::regconfig, CO
ALESCE((schools_1.name)::text, ''::text))) || to_tsvector('simple'::regconfig, COALESCE((schools_1.town)::text, ''::text))) || to_tsvector('simpl
e'::regconfig, COALESCE((schools_1.postcode)::text, ''::text))), '''alper'':*'::tsquery, 0)) DESC, schools.id
         Sort Method: quicksort  Memory: 25kB
         Worker 0:  Sort Method: quicksort  Memory: 25kB
         ->  Nested Loop  (cost=0.29..28593.93 rows=306 width=90) (actual time=122.281..196.059 rows=0 loops=2)
               ->  Parallel Seq Scan on schools  (cost=0.00..2387.41 rows=15306 width=86) (actual time=0.008..11.247 rows=13642 loops=2)
                     Filter: (close_date IS NULL)
                     Rows Removed by Filter: 10873
               ->  Index Scan using schools_pkey on schools schools_1  (cost=0.29..1.69 rows=1 width=61) (actual time=0.013..0.013 rows=0 loops=2
7283)
                     Index Cond: (id = schools.id)
                     Filter: ((((to_tsvector('simple'::regconfig, COALESCE((urn)::text, ''::text)) || to_tsvector('simple'::regconfig, COALESCE((
name)::text, ''::text))) || to_tsvector('simple'::regconfig, COALESCE((town)::text, ''::text))) || to_tsvector('simple'::regconfig, COALESCE((pos
tcode)::text, ''::text))) @@ '''alper'':*'::tsquery)
                     Rows Removed by Filter: 1
 Planning Time: 0.382 ms
 Execution Time: 200.672 ms
(17 rows)
