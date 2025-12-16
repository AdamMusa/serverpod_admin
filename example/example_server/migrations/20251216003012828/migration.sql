BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "comments" (
    "id" bigserial PRIMARY KEY,
    "title" text NOT NULL DEFAULT 'A comment title'::text,
    "description" text NOT NULL DEFAULT 'This is a comment'::text,
    "postId" bigint NOT NULL,
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
CREATE TABLE "posts" (
    "id" bigserial PRIMARY KEY,
    "title" text NOT NULL,
    "description" text NOT NULL,
    "date" timestamp without time zone NOT NULL
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
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "comments"
    ADD CONSTRAINT "comments_fk_0"
    FOREIGN KEY("postId")
    REFERENCES "posts"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR example
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('example', '20251216003012828', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251216003012828', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20251208110420531-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110420531-v3-0-0', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_admin
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_admin', '20251115114801095', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251115114801095', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20251208110412389-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110412389-v3-0-0', "timestamp" = now();


COMMIT;
