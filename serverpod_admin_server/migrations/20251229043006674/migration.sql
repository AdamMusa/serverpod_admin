BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "admin_scope" CASCADE;


--
-- MIGRATION VERSION FOR serverpod_admin
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_admin', '20251229043006674', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251229043006674', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();


COMMIT;
