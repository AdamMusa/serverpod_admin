BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "admin_scope" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "isStaff" boolean NOT NULL,
    "isSuperuser" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "uniq_user" ON "admin_scope" USING btree ("userId");


--
-- MIGRATION VERSION FOR serverpod_admin
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_admin', '20251225051945879', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251225051945879', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();


COMMIT;
