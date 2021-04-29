class AddSearchableToSchools < ActiveRecord::Migration[6.1]
  def up
    add_column :schools, :searchable, :tsvector
    add_index :schools, :searchable, using: :gin
    add_index :schools, :close_date, where: "close_date is NULL"

    execute <<-SQL
      CREATE TEXT SEARCH CONFIGURATION public.schools_search_config (copy=simple);

      CREATE TEXT SEARCH DICTIONARY public.school_dict (
        TEMPLATE = pg_catalog.simple,
        STOPWORDS = english
      );

      ALTER TEXT SEARCH CONFIGURATION public.schools_search_config
      ALTER MAPPING FOR asciiword WITH public.school_dict;

      CREATE FUNCTION school_trigger() RETURNS trigger AS $$
      begin
        new.searchable := to_tsvector(
          'public.schools_search_config',
          CONCAT(new.urn, ' ', new.name, ' ', new.postcode, ' ', REPLACE(new.postcode, ' ', ''), ' ', new.town)
        );
        return new;
      end
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
      ON schools FOR EACH ROW EXECUTE PROCEDURE school_trigger();
    SQL
  end

  def down
    execute <<-SQL
      DROP TEXT SEARCH CONFIGURATION public.schools_search_config;
      DROP TEXT SEARCH DICTIONARY public.schools_search_config;
      DROP FUNCTION school_trigger;
      DROP TRIGGER tsvectorupdate ON schools;
    SQL

    remove_index :schools, :searchable
    remove_index :schools, :close_date
    remove_column :schools, :searchable
  end
end

__END__
irb(main):078:0> SchoolSearch.call(query: "a").analyze
=>
EXPLAIN ANALYZE for: SELECT "schools".* FROM "schools" INNER JOIN (SELECT "schools"."id" AS pg_search_id, (ts_rank(("schools"."searchable"), (to_tsquery('simple', ''' ' || 'a' || ' ''' || ':*')), 0)) AS rank FROM "schools" WHERE (("schools"."searchable") @@ (to_tsquery('simple', ''' ' || 'a
' || ' ''' || ':*')))) AS pg_search_f79e2ecc220dc52eaea688 ON "schools"."id" = pg_search_f79e2ecc220dc52eaea688.pg_search_id WHERE "schools"."close_date" IS NULL ORDER BY pg_search_f79e2ecc220dc52eaea688.rank DESC, "schools"."id" ASC
                                                                         QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=4041.88..4050.85 rows=3586 width=222) (actual time=35.829..36.244 rows=6318 loops=1)
   Sort Key: (ts_rank(schools_1.searchable, '''a'':*'::tsquery, 0)) DESC, schools.id
   Sort Method: quicksort  Memory: 2531kB
   ->  Hash Join  (cost=1912.33..3830.16 rows=3586 width=222) (actual time=12.265..26.560 rows=6318 loops=1)
         Hash Cond: (schools.id = schools_1.id)
         ->  Bitmap Heap Scan on schools  (cost=103.90..1941.26 rows=27236 width=218) (actual time=2.068..7.509 rows=27283 loops=1)
               Recheck Cond: (close_date IS NULL)
               Heap Blocks: exact=1481
               ->  Bitmap Index Scan on index_schools_on_close_date  (cost=0.00..97.09 rows=27236 width=0) (actual time=1.872..1.872 rows=27283 loops=1)
         ->  Hash  (cost=1727.73..1727.73 rows=6456 width=140) (actual time=10.187..10.188 rows=8955 loops=1)
               Buckets: 16384 (originally 8192)  Batches: 1 (originally 1)  Memory Usage: 1718kB
               ->  Bitmap Heap Scan on schools schools_1  (cost=82.03..1727.73 rows=6456 width=140) (actual time=3.010..7.222 rows=8955 loops=1)
                     Recheck Cond: (searchable @@ '''a'':*'::tsquery)
                     Heap Blocks: exact=1469
                     ->  Bitmap Index Scan on index_schools_on_searchable  (cost=0.00..80.42 rows=6456 width=0) (actual time=2.819..2.819 rows=8955 loops=1)
                           Index Cond: (searchable @@ '''a'':*'::tsquery)
 Planning Time: 0.386 ms
 Execution Time: 37.850 ms
(18 rows)

irb(main):079:0> SchoolSearch.call(query: "alper").analyze
=>
EXPLAIN ANALYZE for: SELECT "schools".* FROM "schools" INNER JOIN (SELECT "schools"."id" AS pg_search_id, (ts_rank(("schools"."searchable"), (to_tsquery('simple', ''' ' || 'alper' || ' ''' || ':*')), 0)) AS rank FROM "schools" WHERE (("schools"."searchable") @@ (to_tsquery('simple', ''' ' |
| 'alper' || ' ''' || ':*')))) AS pg_search_f79e2ecc220dc52eaea688 ON "schools"."id" = pg_search_f79e2ecc220dc52eaea688.pg_search_id WHERE "schools"."close_date" IS NULL ORDER BY pg_search_f79e2ecc220dc52eaea688.rank DESC, "schools"."id" ASC
                                                                    QUERY PLAN
--------------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=248.16..248.19 rows=11 width=222) (actual time=0.048..0.049 rows=1 loops=1)
   Sort Key: (ts_rank(schools_1.searchable, '''alper'':*'::tsquery, 0)) DESC, schools.id
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=24.44..247.97 rows=11 width=222) (actual time=0.041..0.042 rows=1 loops=1)
         ->  Bitmap Heap Scan on schools schools_1  (cost=24.15..94.10 rows=19 width=140) (actual time=0.021..0.023 rows=2 loops=1)
               Recheck Cond: (searchable @@ '''alper'':*'::tsquery)
               Heap Blocks: exact=2
               ->  Bitmap Index Scan on index_schools_on_searchable  (cost=0.00..24.14 rows=19 width=0) (actual time=0.017..0.017 rows=2 loops=1)
                     Index Cond: (searchable @@ '''alper'':*'::tsquery)
         ->  Index Scan using schools_pkey on schools  (cost=0.29..8.10 rows=1 width=218) (actual time=0.006..0.006 rows=0 loops=2)
               Index Cond: (id = schools_1.id)
               Filter: (close_date IS NULL)
               Rows Removed by Filter: 0
 Planning Time: 0.506 ms
 Execution Time: 0.094 ms
(15 rows)
