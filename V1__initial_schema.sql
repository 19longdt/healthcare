-- =====================================================
-- BOOKING SERVICE DATABASE SCHEMA
-- =====================================================
-- Version: 1.0
-- Database: PostgreSQL 15+
-- Primary Key: UUID v7 (time-ordered)
-- Normalization: 3NF
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- SECTION 1: REFERENCE/LOOKUP TABLES (External Contexts)
-- These tables store data from external bounded contexts
-- =====================================================

-- -----------------------------------------------------
-- Table: departments
-- Context: Staff (External)
-- Description: Hospital departments/clinics
-- -----------------------------------------------------
CREATE TABLE departments (
    id UUID PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    building VARCHAR(50),
    floor VARCHAR(10),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE departments IS 'Hospital departments/clinics from Staff context';

CREATE INDEX idx_departments_code ON departments(code);
CREATE INDEX idx_departments_active ON departments(is_active) WHERE is_active = TRUE;

-- -----------------------------------------------------
-- Table: specialties
-- Context: Staff (External)
-- Description: Medical specialties
-- -----------------------------------------------------
CREATE TABLE specialties (
    id UUID PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE specialties IS 'Medical specialties from Staff context';

CREATE INDEX idx_specialties_code ON specialties(code);
CREATE INDEX idx_specialties_active ON specialties(is_active) WHERE is_active = TRUE;

-- -----------------------------------------------------
-- Table: department_specialties
-- Junction table: departments <-> specialties (M:N)
-- -----------------------------------------------------
CREATE TABLE department_specialties (
    department_id UUID NOT NULL REFERENCES departments(id) ON DELETE CASCADE,
    specialty_id UUID NOT NULL REFERENCES specialties(id) ON DELETE CASCADE,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (department_id, specialty_id)
);

COMMENT ON TABLE department_specialties IS 'Many-to-many relationship between departments and specialties';

CREATE INDEX idx_dept_spec_specialty ON department_specialties(specialty_id);

-- -----------------------------------------------------
-- Table: doctors
-- Context: Staff (External)
-- Description: Doctor information (Anti-Corruption Layer cache)
-- -----------------------------------------------------
CREATE TABLE doctors (
    id UUID PRIMARY KEY,
    employee_code VARCHAR(20) NOT NULL UNIQUE,
    full_name VARCHAR(150) NOT NULL,
    title VARCHAR(50),
    department_id UUID NOT NULL REFERENCES departments(id),
    email VARCHAR(255),
    phone VARCHAR(20),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE doctors IS 'Doctor information cached from Staff context (ACL)';

CREATE INDEX idx_doctors_employee_code ON doctors(employee_code);
CREATE INDEX idx_doctors_department ON doctors(department_id);
CREATE INDEX idx_doctors_active ON doctors(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_doctors_name ON doctors(full_name);
CREATE INDEX idx_doctors_metadata ON doctors USING GIN (metadata);

-- -----------------------------------------------------
-- Table: doctor_specialties
-- Junction table: doctors <-> specialties (M:N)
-- -----------------------------------------------------
CREATE TABLE doctor_specialties (
    doctor_id UUID NOT NULL REFERENCES doctors(id) ON DELETE CASCADE,
    specialty_id UUID NOT NULL REFERENCES specialties(id) ON DELETE CASCADE,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    years_experience SMALLINT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (doctor_id, specialty_id)
);

COMMENT ON TABLE doctor_specialties IS 'Many-to-many relationship between doctors and specialties';

CREATE INDEX idx_doc_spec_specialty ON doctor_specialties(specialty_id);
CREATE INDEX idx_doc_spec_primary ON doctor_specialties(doctor_id) WHERE is_primary = TRUE;

-- -----------------------------------------------------
-- Table: patients
-- Context: Patient (External)
-- Description: Patient information (Anti-Corruption Layer cache)
-- -----------------------------------------------------
CREATE TABLE patients (
    id UUID PRIMARY KEY,
    patient_code VARCHAR(20) NOT NULL UNIQUE,
    full_name VARCHAR(150) NOT NULL,
    date_of_birth DATE,
    gender VARCHAR(10),
    phone VARCHAR(20),
    email VARCHAR(255),
    address TEXT,
    insurance_number VARCHAR(50),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE patients IS 'Patient information cached from Patient context (ACL)';

CREATE INDEX idx_patients_code ON patients(patient_code);
CREATE INDEX idx_patients_name ON patients(full_name);
CREATE INDEX idx_patients_phone ON patients(phone);
CREATE INDEX idx_patients_email ON patients(email) WHERE email IS NOT NULL;
CREATE INDEX idx_patients_insurance ON patients(insurance_number) WHERE insurance_number IS NOT NULL;
CREATE INDEX idx_patients_metadata ON patients USING GIN (metadata);

-- -----------------------------------------------------
-- Table: locations
-- Description: Physical locations in the hospital
-- -----------------------------------------------------
CREATE TABLE locations (
    id UUID PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    location_type VARCHAR(30) NOT NULL, -- RECEPTION, VITAL_ROOM, EXAM_ROOM, LAB, IMAGING, PHARMACY, CASHIER
    building VARCHAR(50),
    floor VARCHAR(10),
    room_number VARCHAR(20),
    department_id UUID REFERENCES departments(id),
    capacity SMALLINT DEFAULT 1,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE locations IS 'Physical locations in the hospital (rooms, areas)';

CREATE INDEX idx_locations_code ON locations(code);
CREATE INDEX idx_locations_type ON locations(location_type);
CREATE INDEX idx_locations_department ON locations(department_id) WHERE department_id IS NOT NULL;
CREATE INDEX idx_locations_active ON locations(is_active) WHERE is_active = TRUE;

-- -----------------------------------------------------
-- Table: symptoms
-- Description: Symptom catalog for booking
-- -----------------------------------------------------
CREATE TABLE symptoms (
    id UUID PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    severity_level SMALLINT DEFAULT 1, -- 1: Low, 2: Medium, 3: High
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE symptoms IS 'Symptom catalog for booking reason classification';

CREATE INDEX idx_symptoms_code ON symptoms(code);
CREATE INDEX idx_symptoms_category ON symptoms(category);
CREATE INDEX idx_symptoms_active ON symptoms(is_active) WHERE is_active = TRUE;

-- -----------------------------------------------------
-- Table: symptom_specialties
-- Junction table: symptoms -> recommended specialties (M:N)
-- -----------------------------------------------------
CREATE TABLE symptom_specialties (
    symptom_id UUID NOT NULL REFERENCES symptoms(id) ON DELETE CASCADE,
    specialty_id UUID NOT NULL REFERENCES specialties(id) ON DELETE CASCADE,
    priority SMALLINT NOT NULL DEFAULT 1, -- 1: Primary, 2: Secondary
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (symptom_id, specialty_id)
);

COMMENT ON TABLE symptom_specialties IS 'Maps symptoms to recommended specialties';

CREATE INDEX idx_symp_spec_specialty ON symptom_specialties(specialty_id);

-- -----------------------------------------------------
-- Table: holidays
-- Description: Holiday calendar for availability check
-- -----------------------------------------------------
CREATE TABLE holidays (
    id UUID PRIMARY KEY,
    holiday_date DATE NOT NULL,
    name VARCHAR(100) NOT NULL,
    holiday_type VARCHAR(30) NOT NULL, -- NATIONAL, HOSPITAL, DEPARTMENT
    department_id UUID REFERENCES departments(id), -- NULL = applies to all
    is_recurring BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(holiday_date, department_id)
);

COMMENT ON TABLE holidays IS 'Holiday calendar affecting booking availability';

CREATE INDEX idx_holidays_date ON holidays(holiday_date);
CREATE INDEX idx_holidays_type ON holidays(holiday_type);
CREATE INDEX idx_holidays_department ON holidays(department_id) WHERE department_id IS NOT NULL;
CREATE INDEX idx_holidays_recurring ON holidays(is_recurring) WHERE is_recurring = TRUE;

-- =====================================================
-- SECTION 2: CORE DOMAIN TABLES (Booking Context)
-- =====================================================

-- -----------------------------------------------------
-- Table: time_slots (Aggregate Root)
-- Description: Available time slots for booking
-- -----------------------------------------------------
CREATE TABLE time_slots (
    id UUID PRIMARY KEY,
    doctor_id UUID NOT NULL REFERENCES doctors(id),
    department_id UUID NOT NULL REFERENCES departments(id),
    slot_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    slot_status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE', -- AVAILABLE, FULLY_BOOKED, BLOCKED, CANCELLED
    capacity SMALLINT NOT NULL DEFAULT 1,
    booked_count SMALLINT NOT NULL DEFAULT 0,
    version INTEGER NOT NULL DEFAULT 0, -- Optimistic locking
    blocked_reason TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_time_range CHECK (end_time > start_time),
    CONSTRAINT chk_booked_count CHECK (booked_count >= 0 AND booked_count <= capacity),
    CONSTRAINT chk_slot_status CHECK (slot_status IN ('AVAILABLE', 'FULLY_BOOKED', 'BLOCKED', 'CANCELLED')),
    CONSTRAINT uk_slot_doctor_datetime UNIQUE (doctor_id, slot_date, start_time)
);

COMMENT ON TABLE time_slots IS 'Available time slots for doctor appointments (Aggregate Root)';

-- Primary query indexes for time_slots
CREATE INDEX idx_slots_doctor_date ON time_slots(doctor_id, slot_date);
CREATE INDEX idx_slots_department_date ON time_slots(department_id, slot_date);
CREATE INDEX idx_slots_date ON time_slots(slot_date);
CREATE INDEX idx_slots_status ON time_slots(slot_status);

-- Partial index for available slots (most common query)
CREATE INDEX idx_slots_available ON time_slots(doctor_id, slot_date, start_time)
    WHERE slot_status = 'AVAILABLE' AND booked_count < capacity;

-- Composite index for availability search
CREATE INDEX idx_slots_search ON time_slots(department_id, slot_date, slot_status, start_time);

-- BRIN index for time-series data (efficient for large tables)
CREATE INDEX idx_slots_date_brin ON time_slots USING BRIN (slot_date);

-- -----------------------------------------------------
-- Table: bookings (Aggregate Root)
-- Description: Main booking entity
-- -----------------------------------------------------
CREATE TABLE bookings (
    id UUID PRIMARY KEY,
    booking_number VARCHAR(20) NOT NULL UNIQUE, -- Format: BK{YYYYMMDD}{SEQUENCE}
    patient_id UUID NOT NULL REFERENCES patients(id),
    doctor_id UUID NOT NULL REFERENCES doctors(id),
    department_id UUID NOT NULL REFERENCES departments(id),
    time_slot_id UUID NOT NULL REFERENCES time_slots(id),

    -- Booking details
    booking_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    booking_source VARCHAR(30) NOT NULL, -- MOBILE_APP, WEB_APP, CALL_CENTER, PARTNER_API, WALK_IN
    reason TEXT,
    notes TEXT,

    -- Scheduled time (denormalized for query performance)
    scheduled_date DATE NOT NULL,
    scheduled_start_time TIME NOT NULL,
    scheduled_end_time TIME NOT NULL,

    -- Tracking
    confirmed_at TIMESTAMP WITH TIME ZONE,
    confirmed_by UUID,
    checked_in_at TIMESTAMP WITH TIME ZONE,
    completed_at TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    cancelled_by UUID,
    cancellation_reason TEXT,

    -- Idempotency & versioning
    idempotency_key VARCHAR(100),
    version INTEGER NOT NULL DEFAULT 0,

    -- Metadata for flexibility
    metadata JSONB,

    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_booking_status CHECK (
        booking_status IN ('PENDING', 'CONFIRMED', 'REJECTED', 'CANCELLED',
                          'CHECKED_IN', 'IN_PROGRESS', 'COMPLETED', 'NO_SHOW')
    ),
    CONSTRAINT chk_booking_source CHECK (
        booking_source IN ('MOBILE_APP', 'WEB_APP', 'CALL_CENTER', 'PARTNER_API', 'WALK_IN')
    ),
    CONSTRAINT chk_scheduled_time CHECK (scheduled_end_time > scheduled_start_time)
);

COMMENT ON TABLE bookings IS 'Main booking entity (Aggregate Root)';

-- Primary query indexes for bookings
CREATE INDEX idx_bookings_number ON bookings(booking_number);
CREATE INDEX idx_bookings_patient ON bookings(patient_id);
CREATE INDEX idx_bookings_doctor ON bookings(doctor_id);
CREATE INDEX idx_bookings_department ON bookings(department_id);
CREATE INDEX idx_bookings_slot ON bookings(time_slot_id);
CREATE INDEX idx_bookings_status ON bookings(booking_status);
CREATE INDEX idx_bookings_source ON bookings(booking_source);
CREATE INDEX idx_bookings_scheduled_date ON bookings(scheduled_date);

-- Composite indexes for common queries
CREATE INDEX idx_bookings_patient_status ON bookings(patient_id, booking_status);
CREATE INDEX idx_bookings_patient_date ON bookings(patient_id, scheduled_date DESC);
CREATE INDEX idx_bookings_doctor_date ON bookings(doctor_id, scheduled_date, scheduled_start_time);
CREATE INDEX idx_bookings_dept_date_status ON bookings(department_id, scheduled_date, booking_status);

-- Partial indexes for active bookings
CREATE INDEX idx_bookings_pending ON bookings(patient_id, scheduled_date)
    WHERE booking_status = 'PENDING';
CREATE INDEX idx_bookings_confirmed ON bookings(doctor_id, scheduled_date)
    WHERE booking_status = 'CONFIRMED';
CREATE INDEX idx_bookings_active ON bookings(scheduled_date, booking_status)
    WHERE booking_status IN ('PENDING', 'CONFIRMED', 'CHECKED_IN', 'IN_PROGRESS');

-- Idempotency key index
CREATE UNIQUE INDEX idx_bookings_idempotency ON bookings(idempotency_key)
    WHERE idempotency_key IS NOT NULL;

-- BRIN index for time-series queries
CREATE INDEX idx_bookings_created_brin ON bookings USING BRIN (created_at);
CREATE INDEX idx_bookings_scheduled_brin ON bookings USING BRIN (scheduled_date);

-- JSONB index for metadata queries
CREATE INDEX idx_bookings_metadata ON bookings USING GIN (metadata);

-- -----------------------------------------------------
-- Table: booking_symptoms
-- Junction table: bookings <-> symptoms (M:N)
-- -----------------------------------------------------
CREATE TABLE booking_symptoms (
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    symptom_id UUID NOT NULL REFERENCES symptoms(id),
    severity_level SMALLINT DEFAULT 1,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (booking_id, symptom_id)
);

COMMENT ON TABLE booking_symptoms IS 'Symptoms associated with a booking';

CREATE INDEX idx_booking_symptoms_symptom ON booking_symptoms(symptom_id);

-- -----------------------------------------------------
-- Table: timeline_steps (Entity within Booking Aggregate)
-- Description: Steps in the booking timeline
-- -----------------------------------------------------
CREATE TABLE timeline_steps (
    id UUID PRIMARY KEY,
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    step_order SMALLINT NOT NULL,
    step_type VARCHAR(30) NOT NULL, -- CHECK_IN, VITAL_SIGNS, CONSULTATION, LABORATORY, IMAGING, FOLLOW_UP, PRESCRIPTION, PHARMACY, CHECKOUT
    step_name VARCHAR(100) NOT NULL,

    -- Time management
    estimated_duration_minutes SMALLINT NOT NULL,
    estimated_start_time TIME,
    estimated_end_time TIME,
    actual_start_time TIMESTAMP WITH TIME ZONE,
    actual_end_time TIMESTAMP WITH TIME ZONE,

    -- Location
    location_id UUID REFERENCES locations(id),
    location_name VARCHAR(100), -- Denormalized for display

    -- Status
    step_status VARCHAR(20) NOT NULL DEFAULT 'PENDING', -- PENDING, IN_PROGRESS, COMPLETED, SKIPPED, CANCELLED

    -- Conditional step info
    is_mandatory BOOLEAN NOT NULL DEFAULT TRUE,
    condition_type VARCHAR(50), -- SYMPTOM_BASED, DEPARTMENT_BASED, DOCTOR_REQUEST
    condition_value TEXT,

    notes TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_step_type CHECK (
        step_type IN ('CHECK_IN', 'VITAL_SIGNS', 'CONSULTATION', 'LABORATORY',
                      'IMAGING', 'FOLLOW_UP', 'PRESCRIPTION', 'PHARMACY', 'CHECKOUT')
    ),
    CONSTRAINT chk_step_status CHECK (
        step_status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'SKIPPED', 'CANCELLED')
    ),
    CONSTRAINT uk_booking_step_order UNIQUE (booking_id, step_order)
);

COMMENT ON TABLE timeline_steps IS 'Steps in the booking timeline (Entity within Booking Aggregate)';

CREATE INDEX idx_timeline_booking ON timeline_steps(booking_id);
CREATE INDEX idx_timeline_status ON timeline_steps(step_status);
CREATE INDEX idx_timeline_type ON timeline_steps(step_type);
CREATE INDEX idx_timeline_location ON timeline_steps(location_id) WHERE location_id IS NOT NULL;

-- Composite index for booking timeline queries
CREATE INDEX idx_timeline_booking_order ON timeline_steps(booking_id, step_order);

-- =====================================================
-- SECTION 3: EVENT & AUDIT TABLES
-- =====================================================

-- -----------------------------------------------------
-- Table: booking_events (Domain Events / Event Sourcing)
-- Description: Stores all booking-related domain events
-- -----------------------------------------------------
CREATE TABLE booking_events (
    id UUID PRIMARY KEY,
    aggregate_id UUID NOT NULL, -- booking_id
    aggregate_type VARCHAR(50) NOT NULL DEFAULT 'BOOKING',
    event_type VARCHAR(50) NOT NULL, -- BOOKING_CREATED, BOOKING_CONFIRMED, BOOKING_CANCELLED, etc.
    event_version INTEGER NOT NULL,
    payload JSONB NOT NULL,
    metadata JSONB,
    occurred_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    published_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE booking_events IS 'Domain events for event sourcing and audit trail';

CREATE INDEX idx_events_aggregate ON booking_events(aggregate_id);
CREATE INDEX idx_events_type ON booking_events(event_type);
CREATE INDEX idx_events_occurred ON booking_events(occurred_at);
CREATE INDEX idx_events_unpublished ON booking_events(aggregate_id) WHERE published_at IS NULL;

-- BRIN index for time-series
CREATE INDEX idx_events_occurred_brin ON booking_events USING BRIN (occurred_at);

-- JSONB index for payload queries
CREATE INDEX idx_events_payload ON booking_events USING GIN (payload);

-- -----------------------------------------------------
-- Table: booking_status_history
-- Description: Audit trail for booking status changes
-- -----------------------------------------------------
CREATE TABLE booking_status_history (
    id UUID PRIMARY KEY,
    booking_id UUID NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    previous_status VARCHAR(20),
    new_status VARCHAR(20) NOT NULL,
    changed_by UUID,
    change_reason TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE booking_status_history IS 'Audit trail for booking status transitions';

CREATE INDEX idx_status_history_booking ON booking_status_history(booking_id);
CREATE INDEX idx_status_history_created ON booking_status_history(created_at);

-- =====================================================
-- SECTION 4: IDEMPOTENCY & CACHING SUPPORT
-- =====================================================

-- -----------------------------------------------------
-- Table: idempotency_records
-- Description: Stores idempotency keys and their results
-- -----------------------------------------------------
CREATE TABLE idempotency_records (
    id UUID PRIMARY KEY,
    idempotency_key VARCHAR(100) NOT NULL UNIQUE,
    request_hash VARCHAR(64) NOT NULL,
    response_status SMALLINT NOT NULL,
    response_body JSONB,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE idempotency_records IS 'Idempotency keys for preventing duplicate requests';

CREATE INDEX idx_idempotency_key ON idempotency_records(idempotency_key);
CREATE INDEX idx_idempotency_expires ON idempotency_records(expires_at);

-- =====================================================
-- SECTION 5: SEQUENCE FOR BOOKING NUMBER
-- =====================================================

-- Sequence for daily booking number generation
CREATE SEQUENCE IF NOT EXISTS booking_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 20;

-- Function to generate booking number
CREATE OR REPLACE FUNCTION generate_booking_number()
RETURNS VARCHAR(20) AS $$
DECLARE
    v_date VARCHAR(8);
    v_seq INTEGER;
BEGIN
    v_date := TO_CHAR(CURRENT_DATE, 'YYYYMMDD');
    v_seq := NEXTVAL('booking_number_seq');
    RETURN 'BK' || v_date || LPAD(v_seq::TEXT, 6, '0');
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- SECTION 6: TRIGGERS FOR AUTOMATIC UPDATES
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to all tables with updated_at
CREATE TRIGGER trg_departments_updated_at
    BEFORE UPDATE ON departments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_specialties_updated_at
    BEFORE UPDATE ON specialties
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_doctors_updated_at
    BEFORE UPDATE ON doctors
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_patients_updated_at
    BEFORE UPDATE ON patients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_locations_updated_at
    BEFORE UPDATE ON locations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_symptoms_updated_at
    BEFORE UPDATE ON symptoms
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_holidays_updated_at
    BEFORE UPDATE ON holidays
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_time_slots_updated_at
    BEFORE UPDATE ON time_slots
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_bookings_updated_at
    BEFORE UPDATE ON bookings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_timeline_steps_updated_at
    BEFORE UPDATE ON timeline_steps
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- SECTION 7: TRIGGER FOR SLOT STATUS UPDATE
-- =====================================================

-- Function to auto-update slot status based on booked_count
CREATE OR REPLACE FUNCTION update_slot_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.booked_count >= NEW.capacity THEN
        NEW.slot_status := 'FULLY_BOOKED';
    ELSIF NEW.booked_count < NEW.capacity AND OLD.slot_status = 'FULLY_BOOKED' THEN
        NEW.slot_status := 'AVAILABLE';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_slot_status_update
    BEFORE UPDATE OF booked_count ON time_slots
    FOR EACH ROW EXECUTE FUNCTION update_slot_status();

-- =====================================================
-- SECTION 8: VIEWS FOR COMMON QUERIES
-- =====================================================

-- View: Available slots with doctor and department info
CREATE OR REPLACE VIEW v_available_slots AS
SELECT
    ts.id AS slot_id,
    ts.slot_date,
    ts.start_time,
    ts.end_time,
    ts.capacity,
    ts.booked_count,
    (ts.capacity - ts.booked_count) AS available_count,
    d.id AS doctor_id,
    d.full_name AS doctor_name,
    d.title AS doctor_title,
    dept.id AS department_id,
    dept.name AS department_name,
    dept.building,
    dept.floor
FROM time_slots ts
JOIN doctors d ON ts.doctor_id = d.id
JOIN departments dept ON ts.department_id = dept.id
WHERE ts.slot_status = 'AVAILABLE'
    AND ts.booked_count < ts.capacity
    AND ts.slot_date >= CURRENT_DATE
    AND d.is_active = TRUE
    AND dept.is_active = TRUE;

-- View: Booking details with all related info
CREATE OR REPLACE VIEW v_booking_details AS
SELECT
    b.id AS booking_id,
    b.booking_number,
    b.booking_status,
    b.booking_source,
    b.scheduled_date,
    b.scheduled_start_time,
    b.scheduled_end_time,
    b.reason,
    b.notes,
    b.created_at,
    p.id AS patient_id,
    p.patient_code,
    p.full_name AS patient_name,
    p.phone AS patient_phone,
    d.id AS doctor_id,
    d.employee_code AS doctor_code,
    d.full_name AS doctor_name,
    d.title AS doctor_title,
    dept.id AS department_id,
    dept.name AS department_name,
    dept.building AS department_building
FROM bookings b
JOIN patients p ON b.patient_id = p.id
JOIN doctors d ON b.doctor_id = d.id
JOIN departments dept ON b.department_id = dept.id;

-- View: Today's schedule for a doctor
CREATE OR REPLACE VIEW v_today_schedule AS
SELECT
    d.id AS doctor_id,
    d.full_name AS doctor_name,
    b.id AS booking_id,
    b.booking_number,
    b.booking_status,
    b.scheduled_start_time,
    b.scheduled_end_time,
    p.full_name AS patient_name,
    p.patient_code,
    b.reason
FROM bookings b
JOIN doctors d ON b.doctor_id = d.id
JOIN patients p ON b.patient_id = p.id
WHERE b.scheduled_date = CURRENT_DATE
    AND b.booking_status IN ('CONFIRMED', 'CHECKED_IN', 'IN_PROGRESS')
ORDER BY d.id, b.scheduled_start_time;

-- =====================================================
-- SECTION 9: COMMENTS FOR DOCUMENTATION
-- =====================================================

COMMENT ON COLUMN bookings.version IS 'Optimistic locking version number';
COMMENT ON COLUMN bookings.idempotency_key IS 'Unique key to prevent duplicate bookings';
COMMENT ON COLUMN time_slots.version IS 'Optimistic locking version number for concurrency control';
COMMENT ON COLUMN timeline_steps.is_mandatory IS 'TRUE for required steps, FALSE for conditional steps';
COMMENT ON COLUMN timeline_steps.condition_type IS 'Type of condition that triggers this step';
