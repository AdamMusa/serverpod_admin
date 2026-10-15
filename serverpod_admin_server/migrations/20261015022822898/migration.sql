BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "serverpod_admin_log" (
    "id" bigserial PRIMARY KEY,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actor" text NOT NULL,
    "actorName" text,
    "resourceKey" text NOT NULL,
    "recordId" text NOT NULL,
    "action" text NOT NULL,
    "changes" text NOT NULL,
    "summary" text
);

-- Indexes
CREATE INDEX "serverpod_admin_log_record_idx" ON "serverpod_admin_log" USING btree ("resourceKey", "recordId");
CREATE INDEX "serverpod_admin_log_created_idx" ON "serverpod_admin_log" USING btree ("createdAt");


--
-- MIGRATION VERSION FOR serverpod_admin
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_admin', '20261015022822898', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261015022822898', "timestamp" = now();

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
