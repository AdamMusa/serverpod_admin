BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_admin_saved_view" (
    "id" bigserial PRIMARY KEY,
    "owner" text NOT NULL,
    "resourceKey" text NOT NULL,
    "name" text NOT NULL,
    "search" text,
    "sortColumn" text,
    "sortDescending" boolean NOT NULL,
    "filters" json NOT NULL,
    "shownColumns" json,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_admin_saved_view_name_idx" ON "serverpod_admin_saved_view" USING btree ("owner", "resourceKey", "name");


--
-- MIGRATION VERSION FOR serverpod_admin
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_admin', '20261015150410847-saved-views', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261015150410847-saved-views', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260416151914983-insights-perf', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260416151914983-insights-perf', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260417182253191', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260417182253191', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260417182309198', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260417182309198', "timestamp" = now();


COMMIT;
