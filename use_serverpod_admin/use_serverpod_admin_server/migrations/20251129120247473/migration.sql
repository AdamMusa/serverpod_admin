BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "comments" (
    "id" bigserial PRIMARY KEY,
    "title" text NOT NULL,
    "description" text NOT NULL,
    "date" timestamp without time zone NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "persons" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "fullname" text NOT NULL,
    "sexe" text NOT NULL,
    "age" bigint NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "settings" (
    "id" bigserial PRIMARY KEY,
    "theme" text NOT NULL,
    "detailLevel" text NOT NULL,
    "mood" text NOT NULL,
    "language" text NOT NULL,
    "features" json NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);


--
-- MIGRATION VERSION FOR use_serverpod_admin
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('use_serverpod_admin', '20251129120247473', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251129120247473', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();


--
-- MIGRATION VERSION FOR 'serverpod_admin'
--
DELETE FROM "serverpod_migrations"WHERE "module" IN ('serverpod_admin');

COMMIT;
