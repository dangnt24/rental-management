/*
===========================================================
 SYSTEM TABLES (PART 1)
===========================================================
*/

------------------------------------------------------------
-- MODULE
------------------------------------------------------------

CREATE TABLE sy_modules
(
    module_code        VARCHAR(100) PRIMARY KEY,
    module_name        VARCHAR(200) NOT NULL,
    icon               VARCHAR(100),
    description        TEXT,

    sort_order         INTEGER DEFAULT 1,

    is_active          BOOLEAN DEFAULT TRUE,

    created_by         VARCHAR(50),
    created_date       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by         VARCHAR(50),
    updated_date       TIMESTAMP,

    version            INTEGER DEFAULT 1
);

CREATE INDEX idx_sy_modules_active
ON sy_modules(is_active);

------------------------------------------------------------
-- LANGUAGE
------------------------------------------------------------

CREATE TABLE sy_languages
(
    language_code      VARCHAR(10) PRIMARY KEY,

    language_name      VARCHAR(100) NOT NULL,

    culture            VARCHAR(20),

    is_default         BOOLEAN DEFAULT FALSE,

    is_active          BOOLEAN DEFAULT TRUE,

    created_by         VARCHAR(50),
    created_date       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by         VARCHAR(50),
    updated_date       TIMESTAMP,

    version            INTEGER DEFAULT 1
);

CREATE INDEX idx_sy_languages_active
ON sy_languages(is_active);

------------------------------------------------------------
-- TRANSLATION
------------------------------------------------------------

CREATE TABLE sy_translations
(
    translation_key    VARCHAR(200) NOT NULL,

    language_code      VARCHAR(10) NOT NULL,

    translation_value  TEXT NOT NULL,

    module_code        VARCHAR(100),

    remark             TEXT,

    created_by         VARCHAR(50),
    created_date       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by         VARCHAR(50),
    updated_date       TIMESTAMP,

    version            INTEGER DEFAULT 1,

    CONSTRAINT pk_sy_translations
        PRIMARY KEY
        (
            translation_key,
            language_code
        ),

    CONSTRAINT fk_translation_language
        FOREIGN KEY(language_code)
        REFERENCES sy_languages(language_code)
        ON UPDATE CASCADE,

    CONSTRAINT fk_translation_module
        FOREIGN KEY(module_code)
        REFERENCES sy_modules(module_code)
        ON UPDATE CASCADE
);

CREATE INDEX idx_sy_translation_module
ON sy_translations(module_code);

------------------------------------------------------------
-- ROLES
------------------------------------------------------------

CREATE TABLE sy_roles
(
    role_code          VARCHAR(100) PRIMARY KEY,

    role_name          VARCHAR(200) NOT NULL,

    description        TEXT,

    is_system          BOOLEAN DEFAULT FALSE,

    is_active          BOOLEAN DEFAULT TRUE,

    created_by         VARCHAR(50),
    created_date       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by         VARCHAR(50),
    updated_date       TIMESTAMP,

    deleted_by         VARCHAR(50),
    deleted_date       TIMESTAMP,

    is_deleted         BOOLEAN DEFAULT FALSE,

    version            INTEGER DEFAULT 1
);

CREATE INDEX idx_sy_roles_active
ON sy_roles(is_active);

------------------------------------------------------------
-- ROLE DETAILS
------------------------------------------------------------

CREATE TABLE sy_role_details
(
    id                 BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    role_code          VARCHAR(100) NOT NULL,

    resource_type      VARCHAR(50) NOT NULL,

    resource_code      VARCHAR(100) NOT NULL,

    action_code        VARCHAR(50) NOT NULL,

    created_by         VARCHAR(50),
    created_date       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by         VARCHAR(50),
    updated_date       TIMESTAMP,

    version            INTEGER DEFAULT 1,

    CONSTRAINT fk_role_detail_role
        FOREIGN KEY(role_code)
        REFERENCES sy_roles(role_code)
        ON UPDATE CASCADE,

    CONSTRAINT uq_role_detail
        UNIQUE
        (
            role_code,
            resource_type,
            resource_code,
            action_code
        )
);

CREATE INDEX idx_role_detail_role
ON sy_role_details(role_code);

CREATE INDEX idx_role_detail_resource
ON sy_role_details(resource_type, resource_code);

------------------------------------------------------------
-- STATUS
------------------------------------------------------------

CREATE TABLE sy_statuses
(
    status_code        VARCHAR(50) PRIMARY KEY,

    status_name        VARCHAR(200) NOT NULL,

    color              VARCHAR(20),

    icon               VARCHAR(100),

    sort_order         INTEGER DEFAULT 1,

    is_active          BOOLEAN DEFAULT TRUE,

    created_by         VARCHAR(50),
    created_date       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by         VARCHAR(50),
    updated_date       TIMESTAMP,

    version            INTEGER DEFAULT 1
);

------------------------------------------------------------
-- LOOKUP
------------------------------------------------------------

CREATE TABLE sy_lookup_types
(
    lookup_type_code   VARCHAR(100) PRIMARY KEY,

    lookup_type_name   VARCHAR(200) NOT NULL,

    description        TEXT,

    is_active          BOOLEAN DEFAULT TRUE,

    created_by         VARCHAR(50),
    created_date       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by         VARCHAR(50),
    updated_date       TIMESTAMP,

    version            INTEGER DEFAULT 1
);

CREATE TABLE sy_lookup_values
(
    lookup_type_code   VARCHAR(100) NOT NULL,

    lookup_code        VARCHAR(100) NOT NULL,

    lookup_name        VARCHAR(200) NOT NULL,

    sort_order         INTEGER DEFAULT 1,

    color              VARCHAR(30),

    icon               VARCHAR(100),

    is_default         BOOLEAN DEFAULT FALSE,

    is_active          BOOLEAN DEFAULT TRUE,

    created_by         VARCHAR(50),
    created_date       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by         VARCHAR(50),
    updated_date       TIMESTAMP,

    version            INTEGER DEFAULT 1,

    CONSTRAINT pk_lookup_values
        PRIMARY KEY
        (
            lookup_type_code,
            lookup_code
        ),

    CONSTRAINT fk_lookup_type
        FOREIGN KEY(lookup_type_code)
        REFERENCES sy_lookup_types(lookup_type_code)
        ON UPDATE CASCADE
);

CREATE INDEX idx_lookup_active
ON sy_lookup_values(is_active);

/*
===========================================================
SYSTEM TABLES (PART 2)
Users
Functions
Function Actions
Menu
===========================================================
*/

------------------------------------------------------------
-- USERS
------------------------------------------------------------

CREATE TABLE sy_users
(
    user_code              VARCHAR(100) PRIMARY KEY,

    username               VARCHAR(100) NOT NULL,
    password_hash          TEXT NOT NULL,

    full_name              VARCHAR(200) NOT NULL,

    email                  VARCHAR(200),
    phone                  VARCHAR(30),

    avatar_url             TEXT,

    role_code              VARCHAR(100) NOT NULL,

    language_code          VARCHAR(10) DEFAULT 'vi',

    is_system              BOOLEAN DEFAULT FALSE,
    is_locked              BOOLEAN DEFAULT FALSE,
    is_active              BOOLEAN DEFAULT TRUE,

    last_login_date        TIMESTAMP,

    created_by             VARCHAR(50),
    created_date           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by             VARCHAR(50),
    updated_date           TIMESTAMP,

    deleted_by             VARCHAR(50),
    deleted_date           TIMESTAMP,

    is_deleted             BOOLEAN DEFAULT FALSE,

    version                INTEGER DEFAULT 1,

    CONSTRAINT fk_user_role
        FOREIGN KEY(role_code)
        REFERENCES sy_roles(role_code)
        ON UPDATE CASCADE,

    CONSTRAINT fk_user_language
        FOREIGN KEY(language_code)
        REFERENCES sy_languages(language_code)
        ON UPDATE CASCADE
);

CREATE UNIQUE INDEX idx_sy_users_username
ON sy_users(username);

CREATE UNIQUE INDEX idx_sy_users_email
ON sy_users(email);

CREATE INDEX idx_sy_users_role
ON sy_users(role_code);

------------------------------------------------------------
-- USER SESSION
------------------------------------------------------------

CREATE TABLE sy_user_sessions
(
    session_id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_code              VARCHAR(100) NOT NULL,

    access_token           TEXT,

    refresh_token          TEXT,

    ip_address             VARCHAR(100),

    browser                VARCHAR(200),

    device                 VARCHAR(200),

    login_date             TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    expired_date           TIMESTAMP,

    is_revoked             BOOLEAN DEFAULT FALSE,

    CONSTRAINT fk_session_user
        FOREIGN KEY(user_code)
        REFERENCES sy_users(user_code)
        ON UPDATE CASCADE
);

CREATE INDEX idx_session_user
ON sy_user_sessions(user_code);

------------------------------------------------------------
-- FUNCTIONS
------------------------------------------------------------

CREATE TABLE sy_functions
(
    function_code          VARCHAR(100) PRIMARY KEY,

    module_code            VARCHAR(100) NOT NULL,

    function_name          VARCHAR(200) NOT NULL,

    route                  VARCHAR(250),

    icon                   VARCHAR(100),

    description            TEXT,

    sort_order             INTEGER DEFAULT 1,

    is_visible             BOOLEAN DEFAULT TRUE,

    is_active              BOOLEAN DEFAULT TRUE,

    created_by             VARCHAR(50),
    created_date           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by             VARCHAR(50),
    updated_date           TIMESTAMP,

    version                INTEGER DEFAULT 1,

    CONSTRAINT fk_function_module
        FOREIGN KEY(module_code)
        REFERENCES sy_modules(module_code)
        ON UPDATE CASCADE
);

CREATE INDEX idx_function_module
ON sy_functions(module_code);

------------------------------------------------------------
-- FUNCTION ACTIONS
------------------------------------------------------------

CREATE TABLE sy_function_actions
(
    function_code          VARCHAR(100) NOT NULL,

    action_code            VARCHAR(50) NOT NULL,

    action_name            VARCHAR(100) NOT NULL,

    save_history           BOOLEAN DEFAULT FALSE,

    sort_order             INTEGER DEFAULT 1,

    PRIMARY KEY
    (
        function_code,
        action_code
    ),

    CONSTRAINT fk_action_function
        FOREIGN KEY(function_code)
        REFERENCES sy_functions(function_code)
        ON UPDATE CASCADE
);

------------------------------------------------------------
-- MENU
------------------------------------------------------------

CREATE TABLE sy_menu
(
    menu_code              VARCHAR(100) PRIMARY KEY,

    parent_menu_code       VARCHAR(100),

    module_code            VARCHAR(100) NOT NULL,

    function_code          VARCHAR(100),

    menu_name              VARCHAR(200) NOT NULL,

    route                  VARCHAR(250),

    icon                   VARCHAR(100),

    menu_level             SMALLINT DEFAULT 1,

    menu_type              VARCHAR(30) DEFAULT 'SYSTEM',

    sort_order             INTEGER DEFAULT 1,

    is_visible             BOOLEAN DEFAULT TRUE,

    is_active              BOOLEAN DEFAULT TRUE,

    created_by             VARCHAR(50),
    created_date           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by             VARCHAR(50),
    updated_date           TIMESTAMP,

    version                INTEGER DEFAULT 1,

    CONSTRAINT fk_menu_module
        FOREIGN KEY(module_code)
        REFERENCES sy_modules(module_code)
        ON UPDATE CASCADE,

    CONSTRAINT fk_menu_function
        FOREIGN KEY(function_code)
        REFERENCES sy_functions(function_code)
        ON UPDATE CASCADE,

    CONSTRAINT fk_parent_menu
        FOREIGN KEY(parent_menu_code)
        REFERENCES sy_menu(menu_code)
        ON UPDATE CASCADE
);

CREATE INDEX idx_menu_parent
ON sy_menu(parent_menu_code);

CREATE INDEX idx_menu_module
ON sy_menu(module_code);

CREATE INDEX idx_menu_function
ON sy_menu(function_code);

CREATE INDEX idx_menu_sort
ON sy_menu(sort_order);

/*
===========================================================
SYSTEM TABLES (PART 3)
Parameter
Document Number
Mail
Notification
Audit Log
Attachment
===========================================================
*/

------------------------------------------------------------
-- PARAMETERS
------------------------------------------------------------

CREATE TABLE sy_parameters
(
    parameter_type         VARCHAR(100) NOT NULL,

    parameter_code         VARCHAR(100) NOT NULL,

    parameter_name         VARCHAR(200) NOT NULL,

    parameter_value        TEXT,

    description            TEXT,

    is_encrypt             BOOLEAN DEFAULT FALSE,

    created_by             VARCHAR(50),
    created_date           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by             VARCHAR(50),
    updated_date           TIMESTAMP,

    version                INTEGER DEFAULT 1,

    CONSTRAINT pk_sy_parameters
        PRIMARY KEY
        (
            parameter_type,
            parameter_code
        )
);

CREATE INDEX idx_parameter_type
ON sy_parameters(parameter_type);

------------------------------------------------------------
-- DOCUMENT SETTINGS
------------------------------------------------------------

CREATE TABLE sy_document_settings
(
    document_code          VARCHAR(100) PRIMARY KEY,

    document_name          VARCHAR(200) NOT NULL,

    prefix                 VARCHAR(20),

    suffix                 VARCHAR(20),

    running_length         SMALLINT DEFAULT 6,

    current_number         BIGINT DEFAULT 0,

    reset_type             VARCHAR(20) DEFAULT 'YEAR',

    is_active              BOOLEAN DEFAULT TRUE,

    created_by             VARCHAR(50),
    created_date           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by             VARCHAR(50),
    updated_date           TIMESTAMP,

    version                INTEGER DEFAULT 1
);

------------------------------------------------------------
-- MAIL TEMPLATE
------------------------------------------------------------

CREATE TABLE sy_mail_templates
(
    template_code          VARCHAR(100) PRIMARY KEY,

    language_code          VARCHAR(10) NOT NULL,

    subject                VARCHAR(500) NOT NULL,

    body                   TEXT NOT NULL,

    is_html                BOOLEAN DEFAULT TRUE,

    remark                 TEXT,

    created_by             VARCHAR(50),
    created_date           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by             VARCHAR(50),
    updated_date           TIMESTAMP,

    version                INTEGER DEFAULT 1,

    CONSTRAINT fk_mail_template_language
        FOREIGN KEY(language_code)
        REFERENCES sy_languages(language_code)
        ON UPDATE CASCADE
);

------------------------------------------------------------
-- MAIL QUEUE
------------------------------------------------------------

CREATE TABLE sy_mail_queues
(
    id                     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    template_code          VARCHAR(100) NOT NULL,

    reference_type         VARCHAR(100),

    reference_code         VARCHAR(100),

    mail_to               JSONB NOT NULL DEFAULT '[]',

    mail_cc               JSONB DEFAULT '[]',

    mail_bcc              JSONB DEFAULT '[]',

    mail_parameters       JSONB,

    priority               SMALLINT DEFAULT 1,

    status                 VARCHAR(20) DEFAULT 'WAITING',

    retry_count            INTEGER DEFAULT 0,

    max_retry              INTEGER DEFAULT 5,

    error_message          TEXT,

    send_date              TIMESTAMP,

    next_retry_date        TIMESTAMP,

    created_by             VARCHAR(50),
    created_date           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by             VARCHAR(50),
    updated_date           TIMESTAMP,

    version                INTEGER DEFAULT 1,

    CONSTRAINT fk_mail_queue_template
        FOREIGN KEY(template_code)
        REFERENCES sy_mail_templates(template_code)
        ON UPDATE CASCADE
);

CREATE INDEX idx_mail_status
ON sy_mail_queues(status);

CREATE INDEX idx_mail_send
ON sy_mail_queues(send_date);

------------------------------------------------------------
-- NOTIFICATION
------------------------------------------------------------

CREATE TABLE sy_notifications
(
    id                     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    user_code              VARCHAR(100) NOT NULL,

    notification_type      VARCHAR(50),

    title                  VARCHAR(500) NOT NULL,

    message                TEXT NOT NULL,

    reference_type         VARCHAR(100),

    reference_code         VARCHAR(100),

    is_read                BOOLEAN DEFAULT FALSE,

    read_date              TIMESTAMP,

    created_date           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_notification_user
        FOREIGN KEY(user_code)
        REFERENCES sy_users(user_code)
        ON UPDATE CASCADE
);

CREATE INDEX idx_notification_user
ON sy_notifications(user_code);

CREATE INDEX idx_notification_read
ON sy_notifications(is_read);

------------------------------------------------------------
-- AUDIT LOG
------------------------------------------------------------

CREATE TABLE sy_audit_logs
(
    id                     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    user_code              VARCHAR(100),

    module_code            VARCHAR(100),

    function_code          VARCHAR(100),

    action_code            VARCHAR(50),

    reference_code         VARCHAR(100),

    old_data               JSONB,

    new_data               JSONB,

    ip_address             VARCHAR(100),

    browser                VARCHAR(300),

    request_id             VARCHAR(100),

    execution_time_ms      INTEGER,

    created_date           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_audit_user
        FOREIGN KEY(user_code)
        REFERENCES sy_users(user_code)
        ON UPDATE CASCADE,

    CONSTRAINT fk_audit_module
        FOREIGN KEY(module_code)
        REFERENCES sy_modules(module_code)
        ON UPDATE CASCADE,

    CONSTRAINT fk_audit_function
        FOREIGN KEY(function_code)
        REFERENCES sy_functions(function_code)
        ON UPDATE CASCADE
);

CREATE INDEX idx_audit_user
ON sy_audit_logs(user_code);

CREATE INDEX idx_audit_function
ON sy_audit_logs(function_code);

CREATE INDEX idx_audit_date
ON sy_audit_logs(created_date);

------------------------------------------------------------
-- FILE ATTACHMENTS
------------------------------------------------------------

CREATE TABLE sy_file_attachments
(
    id                     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    reference_type         VARCHAR(100) NOT NULL,

    reference_code         VARCHAR(100) NOT NULL,

    file_name              VARCHAR(300) NOT NULL,

    original_name          VARCHAR(300) NOT NULL,

    extension              VARCHAR(20),

    mime_type              VARCHAR(100),

    file_size              BIGINT,

    file_path              TEXT NOT NULL,

    thumbnail_path         TEXT,

    uploaded_by            VARCHAR(50),

    uploaded_date          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    version                INTEGER DEFAULT 1
);

CREATE INDEX idx_attachment_reference
ON sy_file_attachments(reference_type, reference_code);

/*
===========================================================
MASTER TABLES
===========================================================
*/

------------------------------------------------------------
-- BRANCHES
------------------------------------------------------------

CREATE TABLE ms_branches
(
    branch_code             VARCHAR(100) PRIMARY KEY,

    branch_name             VARCHAR(200) NOT NULL,

    phone                   VARCHAR(30),

    email                   VARCHAR(200),

    address                 TEXT,

    description             TEXT,

    is_active               BOOLEAN DEFAULT TRUE,

    created_by              VARCHAR(50),
    created_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by              VARCHAR(50),
    updated_date            TIMESTAMP,

    deleted_by              VARCHAR(50),
    deleted_date            TIMESTAMP,

    is_deleted              BOOLEAN DEFAULT FALSE,

    version                 INTEGER DEFAULT 1
);

------------------------------------------------------------
-- BUILDINGS
------------------------------------------------------------

CREATE TABLE ms_buildings
(
    building_code           VARCHAR(100) PRIMARY KEY,

    branch_code             VARCHAR(100) NOT NULL,

    building_name           VARCHAR(200) NOT NULL,

    address                 TEXT,

    total_floor             SMALLINT,

    description             TEXT,

    is_active               BOOLEAN DEFAULT TRUE,

    created_by              VARCHAR(50),
    created_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by              VARCHAR(50),
    updated_date            TIMESTAMP,

    deleted_by              VARCHAR(50),
    deleted_date            TIMESTAMP,

    is_deleted              BOOLEAN DEFAULT FALSE,

    version                 INTEGER DEFAULT 1,

    CONSTRAINT fk_building_branch
        FOREIGN KEY(branch_code)
        REFERENCES ms_branches(branch_code)
        ON UPDATE CASCADE
);

CREATE INDEX idx_building_branch
ON ms_buildings(branch_code);

------------------------------------------------------------
-- FLOORS
------------------------------------------------------------

CREATE TABLE ms_floors
(
    floor_code              VARCHAR(100) PRIMARY KEY,

    building_code           VARCHAR(100) NOT NULL,

    floor_name              VARCHAR(100) NOT NULL,

    floor_number            SMALLINT,

    description             TEXT,

    is_active               BOOLEAN DEFAULT TRUE,

    created_by              VARCHAR(50),
    created_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by              VARCHAR(50),
    updated_date            TIMESTAMP,

    deleted_by              VARCHAR(50),
    deleted_date            TIMESTAMP,

    is_deleted              BOOLEAN DEFAULT FALSE,

    version                 INTEGER DEFAULT 1,

    CONSTRAINT fk_floor_building
        FOREIGN KEY(building_code)
        REFERENCES ms_buildings(building_code)
        ON UPDATE CASCADE
);

CREATE INDEX idx_floor_building
ON ms_floors(building_code);

------------------------------------------------------------
-- ROOM TYPES
------------------------------------------------------------

CREATE TABLE ms_room_types
(
    room_type_code          VARCHAR(100) PRIMARY KEY,

    room_type_name          VARCHAR(200) NOT NULL,

    description             TEXT,

    is_active               BOOLEAN DEFAULT TRUE,

    created_by              VARCHAR(50),
    created_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by              VARCHAR(50),
    updated_date            TIMESTAMP,

    deleted_by              VARCHAR(50),
    deleted_date            TIMESTAMP,

    is_deleted              BOOLEAN DEFAULT FALSE,

    version                 INTEGER DEFAULT 1
);

------------------------------------------------------------
-- ROOMS
------------------------------------------------------------

CREATE TABLE ms_rooms
(
    room_code               VARCHAR(100) PRIMARY KEY,

    floor_code              VARCHAR(100) NOT NULL,

    room_type_code          VARCHAR(100) NOT NULL,

    room_name               VARCHAR(200) NOT NULL,

    room_status             VARCHAR(100),

    area                    NUMERIC(10,2),

    max_tenant              SMALLINT DEFAULT 1,

    monthly_price           NUMERIC(18,2),

    deposit_amount          NUMERIC(18,2),

    electric_price          NUMERIC(18,2),

    water_price             NUMERIC(18,2),

    internet_price          NUMERIC(18,2),

    parking_price           NUMERIC(18,2),

    note                    TEXT,

    is_active               BOOLEAN DEFAULT TRUE,

    created_by              VARCHAR(50),
    created_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by              VARCHAR(50),
    updated_date            TIMESTAMP,

    deleted_by              VARCHAR(50),
    deleted_date            TIMESTAMP,

    is_deleted              BOOLEAN DEFAULT FALSE,

    version                 INTEGER DEFAULT 1,

    CONSTRAINT fk_room_floor
        FOREIGN KEY(floor_code)
        REFERENCES ms_floors(floor_code)
        ON UPDATE CASCADE,

    CONSTRAINT fk_room_type
        FOREIGN KEY(room_type_code)
        REFERENCES ms_room_types(room_type_code)
        ON UPDATE CASCADE
);

CREATE INDEX idx_room_floor
ON ms_rooms(floor_code);

CREATE INDEX idx_room_status
ON ms_rooms(room_status);

------------------------------------------------------------
-- TENANTS
------------------------------------------------------------

CREATE TABLE ms_tenants
(
    tenant_code             VARCHAR(100) PRIMARY KEY,

    full_name               VARCHAR(200) NOT NULL,

    gender                  VARCHAR(50),

    date_of_birth           DATE,

    phone                   VARCHAR(30),

    email                   VARCHAR(200),

    identity_number         VARCHAR(50),

    identity_issue_date     DATE,

    identity_issue_place    VARCHAR(200),

    permanent_address       TEXT,

    emergency_contact       VARCHAR(200),

    emergency_phone         VARCHAR(30),

    avatar                  TEXT,

    note                    TEXT,

    is_active               BOOLEAN DEFAULT TRUE,

    created_by              VARCHAR(50),
    created_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by              VARCHAR(50),
    updated_date            TIMESTAMP,

    deleted_by              VARCHAR(50),
    deleted_date            TIMESTAMP,

    is_deleted              BOOLEAN DEFAULT FALSE,

    version                 INTEGER DEFAULT 1
);

CREATE UNIQUE INDEX idx_tenant_identity
ON ms_tenants(identity_number);

CREATE INDEX idx_tenant_phone
ON ms_tenants(phone);

------------------------------------------------------------
-- SERVICE TYPES
------------------------------------------------------------

CREATE TABLE ms_service_types
(
    service_code            VARCHAR(100) PRIMARY KEY,

    service_name            VARCHAR(200) NOT NULL,

    calculation_type        VARCHAR(50),

    default_price           NUMERIC(18,2),

    unit                    VARCHAR(50),

    description             TEXT,

    is_active               BOOLEAN DEFAULT TRUE,

    created_by              VARCHAR(50),
    created_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by              VARCHAR(50),
    updated_date            TIMESTAMP,

    version                 INTEGER DEFAULT 1
);

/*
===========================================================
TRANSACTION TABLES
===========================================================
*/

------------------------------------------------------------
-- ROOM SERVICES
------------------------------------------------------------

CREATE TABLE tr_room_services
(
    id                      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    room_code               VARCHAR(100) NOT NULL,

    service_code            VARCHAR(100) NOT NULL,

    unit_price              NUMERIC(18,2) NOT NULL,

    is_active               BOOLEAN DEFAULT TRUE,

    created_by              VARCHAR(50),
    created_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by              VARCHAR(50),
    updated_date            TIMESTAMP,

    version                 INTEGER DEFAULT 1,

    CONSTRAINT fk_room_service_room
        FOREIGN KEY(room_code)
        REFERENCES ms_rooms(room_code)
        ON UPDATE CASCADE,

    CONSTRAINT fk_room_service_type
        FOREIGN KEY(service_code)
        REFERENCES ms_service_types(service_code)
        ON UPDATE CASCADE,

    CONSTRAINT uq_room_service
        UNIQUE(room_code, service_code)
);

------------------------------------------------------------
-- CONTRACTS
------------------------------------------------------------

CREATE TABLE tr_contracts
(
    contract_id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    contract_no             VARCHAR(100) NOT NULL UNIQUE,

    room_code               VARCHAR(100) NOT NULL,

    tenant_code             VARCHAR(100) NOT NULL,

    contract_status         VARCHAR(50),

    start_date              DATE NOT NULL,

    end_date                DATE,

    deposit_amount          NUMERIC(18,2),

    monthly_price           NUMERIC(18,2),

    note                    TEXT,

    created_by              VARCHAR(50),
    created_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by              VARCHAR(50),
    updated_date            TIMESTAMP,

    deleted_by              VARCHAR(50),
    deleted_date            TIMESTAMP,

    is_deleted              BOOLEAN DEFAULT FALSE,

    version                 INTEGER DEFAULT 1,

    CONSTRAINT fk_contract_room
        FOREIGN KEY(room_code)
        REFERENCES ms_rooms(room_code)
        ON UPDATE CASCADE,

    CONSTRAINT fk_contract_tenant
        FOREIGN KEY(tenant_code)
        REFERENCES ms_tenants(tenant_code)
        ON UPDATE CASCADE
);

------------------------------------------------------------
-- ELECTRIC / WATER READING
------------------------------------------------------------

CREATE TABLE tr_meter_readings
(
    reading_id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    room_code               VARCHAR(100) NOT NULL,

    service_code            VARCHAR(100) NOT NULL,

    reading_month           DATE NOT NULL,

    previous_number         NUMERIC(18,2) NOT NULL,

    current_number          NUMERIC(18,2) NOT NULL,

    quantity                NUMERIC(18,2) GENERATED ALWAYS AS
    (
        current_number - previous_number
    ) STORED,

    note                    TEXT,

    created_by              VARCHAR(50),
    created_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by              VARCHAR(50),
    updated_date            TIMESTAMP,

    version                 INTEGER DEFAULT 1,

    CONSTRAINT fk_meter_room
        FOREIGN KEY(room_code)
        REFERENCES ms_rooms(room_code)
        ON UPDATE CASCADE,

    CONSTRAINT fk_meter_service
        FOREIGN KEY(service_code)
        REFERENCES ms_service_types(service_code)
        ON UPDATE CASCADE
);

------------------------------------------------------------
-- INVOICE
------------------------------------------------------------

CREATE TABLE tr_invoices
(
    invoice_id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    invoice_no              VARCHAR(100) NOT NULL UNIQUE,

    contract_id             BIGINT NOT NULL,

    invoice_month           DATE NOT NULL,

    invoice_status          VARCHAR(50),

    total_amount            NUMERIC(18,2),

    paid_amount             NUMERIC(18,2) DEFAULT 0,

    due_date                DATE,

    note                    TEXT,

    created_by              VARCHAR(50),
    created_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by              VARCHAR(50),
    updated_date            TIMESTAMP,

    deleted_by              VARCHAR(50),
    deleted_date            TIMESTAMP,

    is_deleted              BOOLEAN DEFAULT FALSE,

    version                 INTEGER DEFAULT 1,

    CONSTRAINT fk_invoice_contract
        FOREIGN KEY(contract_id)
        REFERENCES tr_contracts(contract_id)
);

/*
===========================================================
TRANSACTION TABLES (CONTINUE)
Contract Members
Room Transfer
Incident
Receipt
===========================================================
*/

------------------------------------------------------------
-- CONTRACT MEMBERS
------------------------------------------------------------

CREATE TABLE tr_contract_members
(
    id                      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    contract_id             BIGINT NOT NULL,

    tenant_code             VARCHAR(100) NOT NULL,

    relationship_code       VARCHAR(50),

    is_representative       BOOLEAN DEFAULT FALSE,

    move_in_date            DATE,

    move_out_date           DATE,

    note                    TEXT,

    created_by              VARCHAR(50),
    created_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by              VARCHAR(50),
    updated_date            TIMESTAMP,

    version                 INTEGER DEFAULT 1,

    CONSTRAINT fk_contract_member_contract
        FOREIGN KEY(contract_id)
        REFERENCES tr_contracts(contract_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_contract_member_tenant
        FOREIGN KEY(tenant_code)
        REFERENCES ms_tenants(tenant_code)
        ON UPDATE CASCADE,

    CONSTRAINT uq_contract_member
        UNIQUE(contract_id, tenant_code)
);

CREATE INDEX idx_contract_member_contract
ON tr_contract_members(contract_id);

------------------------------------------------------------
-- ROOM TRANSFER HISTORY
------------------------------------------------------------

CREATE TABLE tr_room_transfers
(
    transfer_id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    contract_id             BIGINT NOT NULL,

    from_room_code          VARCHAR(100) NOT NULL,

    to_room_code            VARCHAR(100) NOT NULL,

    transfer_date           DATE NOT NULL,

    reason                  TEXT,

    transfer_fee            NUMERIC(18,2) DEFAULT 0,

    created_by              VARCHAR(50),
    created_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by              VARCHAR(50),
    updated_date            TIMESTAMP,

    version                 INTEGER DEFAULT 1,

    CONSTRAINT fk_transfer_contract
        FOREIGN KEY(contract_id)
        REFERENCES tr_contracts(contract_id),

    CONSTRAINT fk_transfer_from_room
        FOREIGN KEY(from_room_code)
        REFERENCES ms_rooms(room_code),

    CONSTRAINT fk_transfer_to_room
        FOREIGN KEY(to_room_code)
        REFERENCES ms_rooms(room_code)
);

CREATE INDEX idx_transfer_contract
ON tr_room_transfers(contract_id);

------------------------------------------------------------
-- INCIDENT
------------------------------------------------------------

CREATE TABLE tr_incidents
(
    incident_id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    incident_no             VARCHAR(100) NOT NULL UNIQUE,

    room_code               VARCHAR(100) NOT NULL,

    tenant_code             VARCHAR(100),

    incident_type           VARCHAR(50),

    priority                VARCHAR(30),

    status                  VARCHAR(30),

    title                   VARCHAR(300) NOT NULL,

    description             TEXT,

    assigned_to             VARCHAR(100),

    completed_date          TIMESTAMP,

    note                    TEXT,

    created_by              VARCHAR(50),
    created_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by              VARCHAR(50),
    updated_date            TIMESTAMP,

    version                 INTEGER DEFAULT 1,

    CONSTRAINT fk_incident_room
        FOREIGN KEY(room_code)
        REFERENCES ms_rooms(room_code),

    CONSTRAINT fk_incident_tenant
        FOREIGN KEY(tenant_code)
        REFERENCES ms_tenants(tenant_code),

    CONSTRAINT fk_incident_user
        FOREIGN KEY(assigned_to)
        REFERENCES sy_users(user_code)
);

CREATE INDEX idx_incident_room
ON tr_incidents(room_code);

CREATE INDEX idx_incident_status
ON tr_incidents(status);

------------------------------------------------------------
-- RECEIPT
------------------------------------------------------------

CREATE TABLE tr_receipts
(
    receipt_id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    receipt_no              VARCHAR(100) NOT NULL UNIQUE,

    payment_id              BIGINT NOT NULL,

    receipt_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    amount                  NUMERIC(18,2) NOT NULL,

    receiver                VARCHAR(100),

    note                    TEXT,

    created_by              VARCHAR(50),
    created_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    version                 INTEGER DEFAULT 1,

    CONSTRAINT fk_receipt_payment
        FOREIGN KEY(payment_id)
        REFERENCES tr_payments(payment_id)
);

------------------------------------------------------------
-- ROOM IMAGES
------------------------------------------------------------

CREATE TABLE tr_room_images
(
    id                      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    room_code               VARCHAR(100) NOT NULL,

    attachment_id           BIGINT NOT NULL,

    sort_order              INTEGER DEFAULT 1,

    is_thumbnail            BOOLEAN DEFAULT FALSE,

    CONSTRAINT fk_room_image_room
        FOREIGN KEY(room_code)
        REFERENCES ms_rooms(room_code),

    CONSTRAINT fk_room_image_attachment
        FOREIGN KEY(attachment_id)
        REFERENCES sy_file_attachments(id)
);

------------------------------------------------------------
-- ROOM POSTS
------------------------------------------------------------

CREATE TABLE tr_room_posts
(
    post_id                 BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    room_code               VARCHAR(100) NOT NULL,

    title                   VARCHAR(500) NOT NULL,

    slug                    VARCHAR(500) NOT NULL UNIQUE,

    short_description       TEXT,

    content                 TEXT,

    seo_title               VARCHAR(500),

    seo_description         TEXT,

    seo_keywords            VARCHAR(500),

    published_date          TIMESTAMP,

    expired_date            TIMESTAMP,

    view_count              INTEGER DEFAULT 0,

    is_featured             BOOLEAN DEFAULT FALSE,

    status                  VARCHAR(30) DEFAULT 'DRAFT',

    created_by              VARCHAR(50),
    created_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by              VARCHAR(50),
    updated_date            TIMESTAMP,

    version                 INTEGER DEFAULT 1,

    CONSTRAINT fk_post_room
        FOREIGN KEY(room_code)
        REFERENCES ms_rooms(room_code)
);

CREATE INDEX idx_post_status
ON tr_room_posts(status);

CREATE INDEX idx_post_room
ON tr_room_posts(room_code);

/*
===========================================================
TRANSACTION TABLES (PORTAL)
Favorite
Viewing Schedule
Contact Request
Search History
===========================================================
*/

------------------------------------------------------------
-- FAVORITE ROOMS
------------------------------------------------------------

CREATE TABLE tr_favorite_rooms
(
    id                      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    user_code               VARCHAR(100) NOT NULL,

    room_code               VARCHAR(100) NOT NULL,

    created_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_favorite_user
        FOREIGN KEY(user_code)
        REFERENCES sy_users(user_code)
        ON UPDATE CASCADE,

    CONSTRAINT fk_favorite_room
        FOREIGN KEY(room_code)
        REFERENCES ms_rooms(room_code)
        ON UPDATE CASCADE,

    CONSTRAINT uq_favorite
        UNIQUE(user_code, room_code)
);

CREATE INDEX idx_favorite_user
ON tr_favorite_rooms(user_code);

------------------------------------------------------------
-- VIEWING SCHEDULE
------------------------------------------------------------

CREATE TABLE tr_room_viewings
(
    viewing_id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    room_code               VARCHAR(100) NOT NULL,

    customer_name           VARCHAR(200) NOT NULL,

    phone                   VARCHAR(30),

    email                   VARCHAR(200),

    viewing_time            TIMESTAMP NOT NULL,

    status                  VARCHAR(30) DEFAULT 'WAITING',

    note                    TEXT,

    created_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_viewing_room
        FOREIGN KEY(room_code)
        REFERENCES ms_rooms(room_code)
);

CREATE INDEX idx_viewing_room
ON tr_room_viewings(room_code);

------------------------------------------------------------
-- CONTACT REQUEST
------------------------------------------------------------

CREATE TABLE tr_contact_requests
(
    request_id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    room_code               VARCHAR(100),

    customer_name           VARCHAR(200) NOT NULL,

    phone                   VARCHAR(30),

    email                   VARCHAR(200),

    title                   VARCHAR(300),

    content                 TEXT,

    status                  VARCHAR(30) DEFAULT 'NEW',

    created_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_contact_room
        FOREIGN KEY(room_code)
        REFERENCES ms_rooms(room_code)
);

CREATE INDEX idx_contact_status
ON tr_contact_requests(status);

------------------------------------------------------------
-- SEARCH HISTORY
------------------------------------------------------------

CREATE TABLE tr_search_histories
(
    history_id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    user_code               VARCHAR(100),

    keyword                 VARCHAR(500),

    city                    VARCHAR(100),

    district                VARCHAR(100),

    ward                    VARCHAR(100),

    room_type               VARCHAR(100),

    min_price               NUMERIC(18,2),

    max_price               NUMERIC(18,2),

    created_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_search_user
        FOREIGN KEY(user_code)
        REFERENCES sy_users(user_code)
        ON UPDATE CASCADE
);

CREATE INDEX idx_search_user
ON tr_search_histories(user_code);

------------------------------------------------------------
-- RECENTLY VIEWED ROOM
------------------------------------------------------------

CREATE TABLE tr_recent_rooms
(
    id                      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    user_code               VARCHAR(100),

    room_code               VARCHAR(100) NOT NULL,

    viewed_date             TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_recent_user
        FOREIGN KEY(user_code)
        REFERENCES sy_users(user_code)
        ON UPDATE CASCADE,

    CONSTRAINT fk_recent_room
        FOREIGN KEY(room_code)
        REFERENCES ms_rooms(room_code)
        ON UPDATE CASCADE
);

CREATE INDEX idx_recent_user
ON tr_recent_rooms(user_code);

------------------------------------------------------------
-- ANNOUNCEMENT
------------------------------------------------------------

CREATE TABLE tr_announcements
(
    announcement_id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    title                   VARCHAR(500) NOT NULL,

    content                 TEXT,

    start_date              TIMESTAMP,

    end_date                TIMESTAMP,

    is_popup                BOOLEAN DEFAULT FALSE,

    is_active               BOOLEAN DEFAULT TRUE,

    created_by              VARCHAR(50),
    created_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by              VARCHAR(50),
    updated_date            TIMESTAMP,

    version                 INTEGER DEFAULT 1
);

------------------------------------------------------------
-- BANNER
------------------------------------------------------------

CREATE TABLE tr_banners
(
    banner_id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    title                   VARCHAR(300),

    image_attachment_id     BIGINT NOT NULL,

    redirect_url            TEXT,

    sort_order              INTEGER DEFAULT 1,

    start_date              TIMESTAMP,

    end_date                TIMESTAMP,

    is_active               BOOLEAN DEFAULT TRUE,

    created_by              VARCHAR(50),
    created_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_by              VARCHAR(50),
    updated_date            TIMESTAMP,

    version                 INTEGER DEFAULT 1,

    CONSTRAINT fk_banner_attachment
        FOREIGN KEY(image_attachment_id)
        REFERENCES sy_file_attachments(id)
);

------------------------------------------------------------
-- SYSTEM LOG
------------------------------------------------------------

CREATE TABLE sy_system_logs
(
    id                      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    level                   VARCHAR(20),

    source                  VARCHAR(200),

    message                 TEXT,

    exception               TEXT,

    stack_trace             TEXT,

    created_date            TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_system_log_level
ON sy_system_logs(level);

CREATE INDEX idx_system_log_date
ON sy_system_logs(created_date);

/*
===========================================================
FOREIGN KEY
CHECK
UNIQUE
===========================================================
*/

------------------------------------------------------------
-- USER
------------------------------------------------------------

ALTER TABLE sy_users
ADD CONSTRAINT uq_sy_users_username
UNIQUE(username);

ALTER TABLE sy_users
ADD CONSTRAINT uq_sy_users_email
UNIQUE(email);

------------------------------------------------------------
-- ROLE
------------------------------------------------------------

ALTER TABLE sy_roles
ADD CONSTRAINT uq_sy_roles_name
UNIQUE(role_name);

------------------------------------------------------------
-- MODULE
------------------------------------------------------------

ALTER TABLE sy_modules
ADD CONSTRAINT uq_sy_modules_name
UNIQUE(module_name);

------------------------------------------------------------
-- LANGUAGE
------------------------------------------------------------

ALTER TABLE sy_languages
ADD CONSTRAINT uq_sy_languages_name
UNIQUE(language_name);

------------------------------------------------------------
-- ROOM
------------------------------------------------------------

ALTER TABLE ms_rooms
ADD CONSTRAINT uq_room_name
UNIQUE(room_name);

------------------------------------------------------------
-- ROOM TYPE
------------------------------------------------------------

ALTER TABLE ms_room_types
ADD CONSTRAINT uq_room_type_name
UNIQUE(room_type_name);

------------------------------------------------------------
-- TENANT
------------------------------------------------------------

ALTER TABLE ms_tenants
ADD CONSTRAINT chk_email
CHECK
(
    email IS NULL
    OR email LIKE '%@%'
);

ALTER TABLE ms_tenants
ADD CONSTRAINT chk_phone
CHECK
(
    phone IS NULL
    OR length(phone)>=9
);

------------------------------------------------------------
-- CONTRACT
------------------------------------------------------------

ALTER TABLE tr_contracts
ADD CONSTRAINT chk_contract_date
CHECK
(
    end_date IS NULL
    OR end_date>=start_date
);

------------------------------------------------------------
-- INVOICE
------------------------------------------------------------

ALTER TABLE tr_invoices
ADD CONSTRAINT chk_invoice_money
CHECK
(
    total_amount>=0
);

------------------------------------------------------------
-- PAYMENT
------------------------------------------------------------

ALTER TABLE tr_payments
ADD CONSTRAINT chk_payment_amount
CHECK
(
    payment_amount>0
);

------------------------------------------------------------
-- METER
------------------------------------------------------------

ALTER TABLE tr_meter_readings
ADD CONSTRAINT chk_meter
CHECK
(
    current_number>=previous_number
);

------------------------------------------------------------
-- ROOM SERVICE
------------------------------------------------------------

ALTER TABLE tr_room_services
ADD CONSTRAINT chk_room_service_price
CHECK
(
    unit_price>=0
);

/*
===========================================================
INDEX
===========================================================
*/

CREATE INDEX idx_room_status
ON ms_rooms(room_status);

CREATE INDEX idx_room_type
ON ms_rooms(room_type_code);

CREATE INDEX idx_room_floor
ON ms_rooms(floor_code);

CREATE INDEX idx_contract_room
ON tr_contracts(room_code);

CREATE INDEX idx_contract_tenant
ON tr_contracts(tenant_code);

CREATE INDEX idx_contract_status
ON tr_contracts(contract_status);

CREATE INDEX idx_invoice_contract
ON tr_invoices(contract_id);

CREATE INDEX idx_invoice_month
ON tr_invoices(invoice_month);

CREATE INDEX idx_invoice_status
ON tr_invoices(invoice_status);

CREATE INDEX idx_payment_invoice
ON tr_payments(invoice_id);

CREATE INDEX idx_meter_room
ON tr_meter_readings(room_code);

CREATE INDEX idx_meter_month
ON tr_meter_readings(reading_month);

CREATE INDEX idx_post_room
ON tr_room_posts(room_code);

CREATE INDEX idx_post_status
ON tr_room_posts(status);

CREATE INDEX idx_notification_user
ON sy_notifications(user_code);

CREATE INDEX idx_notification_read
ON sy_notifications(is_read);

CREATE INDEX idx_translation_key
ON sy_translations(translation_key);

CREATE INDEX idx_lookup_type
ON sy_lookup_values(lookup_type_code);

CREATE INDEX idx_lookup_active
ON sy_lookup_values(is_active);

CREATE INDEX idx_attachment_ref
ON sy_file_attachments(reference_type,reference_code);

CREATE INDEX idx_audit_user
ON sy_audit_logs(user_code);

CREATE INDEX idx_audit_date
ON sy_audit_logs(created_date);

CREATE INDEX idx_mail_queue_status
ON sy_mail_queues(status);

CREATE INDEX idx_mail_queue_retry
ON sy_mail_queues(next_retry_date);