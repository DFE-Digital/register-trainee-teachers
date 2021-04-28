class AddSearchableToSchools < ActiveRecord::Migration[6.1]
  def up
    add_column :schools, :searchable, :tsvector
    add_index :schools, :searchable, using: :gin

    execute <<-SQL
      CREATE TEXT SEARCH CONFIGURATION public.schools_search_config (copy=simple);

      CREATE TEXT SEARCH DICTIONARY public.school_dict (
        TEMPLATE = pg_catalog.simple,
        STOPWORDS = english
      );

      ALTER TEXT SEARCH CONFIGURATION public.schools_search_config
      ALTER MAPPING FOR asciiword WITH public.school_dict;

      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON schools FOR EACH ROW EXECUTE PROCEDURE
      tsvector_update_trigger(searchable, 'public.schools_search_config', urn, name, postcode, town);
    SQL
  end

  def down
    execute <<-SQL
      DROP TEXT SEARCH CONFIGURATION public.schools_search_config
      DROP TEXT SEARCH DICTIONARY public.schools_search_config
      DROP TRIGGER tsvectorupdate ON schools;
    SQL

    remove_index :schools, :searchable
    remove_column :schools, :searchable
  end
end

__END__
irb(main):013:0> SchoolSearch.call(query: "a").analyze
=>
EXPLAIN ANALYZE for: SELECT "schools".* FROM "schools" INNER JOIN (SELECT "schools"."id" AS pg_search_id, (ts_rank(("schools"."searchable"), (to_
tsquery('simple', ''' ' || 'a' || ' ''' || ':*')), 0)) AS rank FROM "schools" WHERE (("schools"."searchable") @@ (to_tsquery('simple', ''' ' || '
a' || ' ''' || ':*')))) AS pg_search_f79e2ecc220dc52eaea688 ON "schools"."id" = pg_search_f79e2ecc220dc52eaea688.pg_search_id WHERE "schools"."cl
ose_date" IS NULL ORDER BY pg_search_f79e2ecc220dc52eaea688.rank DESC, "schools"."id" ASC
                                                                         QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------------------------
------------
 Sort  (cost=3962.35..3971.37 rows=3606 width=207) (actual time=42.427..42.885 rows=6318 loops=1)
   Sort Key: (ts_rank(schools_1.searchable, '''a'':*'::tsquery, 0)) DESC, schools.id
   Sort Method: quicksort  Memory: 2320kB
   ->  Hash Join  (cost=1711.45..3749.30 rows=3606 width=207) (actual time=10.447..31.089 rows=6318 loops=1)
         Hash Cond: (schools.id = schools_1.id)
         ->  Seq Scan on schools  (cost=0.00..1957.29 rows=27252 width=203) (actual time=0.006..11.824 rows=27283 loops=1)
               Filter: (close_date IS NULL)
               Rows Removed by Filter: 21746
         ->  Hash  (cost=1630.36..1630.36 rows=6487 width=125) (actual time=10.422..10.423 rows=8955 loops=1)
               Buckets: 16384 (originally 8192)  Batches: 1 (originally 1)  Memory Usage: 1586kB
               ->  Bitmap Heap Scan on schools schools_1  (cost=82.28..1630.36 rows=6487 width=125) (actual time=3.023..7.221 rows=8955 loops=1)
                     Recheck Cond: (searchable @@ '''a'':*'::tsquery)
                     Heap Blocks: exact=1379
                     ->  Bitmap Index Scan on index_schools_on_searchable  (cost=0.00..80.66 rows=6487 width=0) (actual time=2.849..2.849 rows=89
55 loops=1)
                           Index Cond: (searchable @@ '''a'':*'::tsquery)
 Planning Time: 0.365 ms
 Execution Time: 44.405 ms
(17 rows)

irb(main):019:0> SchoolSearch.call(query: "alper").analyze
=>
EXPLAIN ANALYZE for: SELECT "schools".* FROM "schools" INNER JOIN (SELECT "schools"."id" AS pg_search_id, (ts_rank(("schools"."searchable"), (to_
tsquery('simple', ''' ' || 'alper' || ' ''' || ':*')), 0)) AS rank FROM "schools" WHERE (("schools"."searchable") @@ (to_tsquery('simple', ''' '
|| 'alper' || ' ''' || ':*')))) AS pg_search_f79e2ecc220dc52eaea688 ON "schools"."id" = pg_search_f79e2ecc220dc52eaea688.pg_search_id WHERE "scho
ols"."close_date" IS NULL ORDER BY pg_search_f79e2ecc220dc52eaea688.rank DESC, "schools"."id" ASC
                                                                    QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------------------------
-
 Sort  (cost=247.96..247.98 rows=11 width=207) (actual time=0.048..0.049 rows=1 loops=1)
   Sort Key: (ts_rank(schools_1.searchable, '''alper'':*'::tsquery, 0)) DESC, schools.id
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=24.44..247.77 rows=11 width=207) (actual time=0.041..0.043 rows=1 loops=1)
         ->  Bitmap Heap Scan on schools schools_1  (cost=24.15..93.90 rows=19 width=125) (actual time=0.020..0.022 rows=2 loops=1)
               Recheck Cond: (searchable @@ '''alper'':*'::tsquery)
               Heap Blocks: exact=2
               ->  Bitmap Index Scan on index_schools_on_searchable  (cost=0.00..24.14 rows=19 width=0) (actual time=0.017..0.017 rows=2 loops=1)
                     Index Cond: (searchable @@ '''alper'':*'::tsquery)
         ->  Index Scan using schools_pkey on schools  (cost=0.29..8.10 rows=1 width=203) (actual time=0.007..0.007 rows=0 loops=2)
               Index Cond: (id = schools_1.id)
               Filter: (close_date IS NULL)
               Rows Removed by Filter: 0
 Planning Time: 0.481 ms
 Execution Time: 1.250 ms
