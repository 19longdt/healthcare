-- ===========================================
-- Seed Mock Data for Development/Testing
-- ===========================================
-- This migration inserts sample data for development and testing purposes
-- In production, this file should be excluded or data should be loaded differently

-- ===========================================
-- Departments
-- ===========================================
INSERT INTO departments (id, code, name, description, building, floor, is_active, created_at, updated_at) VALUES
('019391a0-0001-7000-8000-000000000001', 'DEPT-INT', 'Internal Medicine', 'General internal medicine department', 'Building A', '2', true, NOW(), NOW()),
('019391a0-0001-7000-8000-000000000002', 'DEPT-CAR', 'Cardiology', 'Heart and cardiovascular care', 'Building A', '3', true, NOW(), NOW()),
('019391a0-0001-7000-8000-000000000003', 'DEPT-ORT', 'Orthopedics', 'Bone and joint care', 'Building B', '1', true, NOW(), NOW()),
('019391a0-0001-7000-8000-000000000004', 'DEPT-PED', 'Pediatrics', 'Child healthcare', 'Building C', '1', true, NOW(), NOW()),
('019391a0-0001-7000-8000-000000000005', 'DEPT-DER', 'Dermatology', 'Skin care and treatment', 'Building A', '4', true, NOW(), NOW());

-- ===========================================
-- Specialties
-- ===========================================
INSERT INTO specialties (id, code, name, description, is_active, created_at, updated_at) VALUES
('019391a0-0002-7000-8000-000000000001', 'SPEC-GEN', 'General Medicine', 'General medical practice', true, NOW(), NOW()),
('019391a0-0002-7000-8000-000000000002', 'SPEC-CAR', 'Cardiology', 'Heart specialist', true, NOW(), NOW()),
('019391a0-0002-7000-8000-000000000003', 'SPEC-ORT', 'Orthopedics', 'Bone and joint specialist', true, NOW(), NOW()),
('019391a0-0002-7000-8000-000000000004', 'SPEC-PED', 'Pediatrics', 'Child health specialist', true, NOW(), NOW()),
('019391a0-0002-7000-8000-000000000005', 'SPEC-DER', 'Dermatology', 'Skin specialist', true, NOW(), NOW()),
('019391a0-0002-7000-8000-000000000006', 'SPEC-NEU', 'Neurology', 'Nervous system specialist', true, NOW(), NOW());

-- ===========================================
-- Department-Specialty Mapping
-- ===========================================
INSERT INTO department_specialties (department_id, specialty_id, is_primary, created_at) VALUES
('019391a0-0001-7000-8000-000000000001', '019391a0-0002-7000-8000-000000000001', true, NOW()),
('019391a0-0001-7000-8000-000000000002', '019391a0-0002-7000-8000-000000000002', true, NOW()),
('019391a0-0001-7000-8000-000000000003', '019391a0-0002-7000-8000-000000000003', true, NOW()),
('019391a0-0001-7000-8000-000000000004', '019391a0-0002-7000-8000-000000000004', true, NOW()),
('019391a0-0001-7000-8000-000000000005', '019391a0-0002-7000-8000-000000000005', true, NOW());

-- ===========================================
-- Doctors
-- ===========================================
INSERT INTO doctors (id, employee_code, full_name, title, department_id, email, phone, is_active, created_at, updated_at) VALUES
('019391a0-0003-7000-8000-000000000001', 'DOC-001', 'Dr. Nguyen Van A', 'Senior Physician', '019391a0-0001-7000-8000-000000000001', 'nguyenvana@hospital.com', '0901234001', true, NOW(), NOW()),
('019391a0-0003-7000-8000-000000000002', 'DOC-002', 'Dr. Tran Thi B', 'Cardiologist', '019391a0-0001-7000-8000-000000000002', 'tranthib@hospital.com', '0901234002', true, NOW(), NOW()),
('019391a0-0003-7000-8000-000000000003', 'DOC-003', 'Dr. Le Van C', 'Orthopedic Surgeon', '019391a0-0001-7000-8000-000000000003', 'levanc@hospital.com', '0901234003', true, NOW(), NOW()),
('019391a0-0003-7000-8000-000000000004', 'DOC-004', 'Dr. Pham Thi D', 'Pediatrician', '019391a0-0001-7000-8000-000000000004', 'phamthid@hospital.com', '0901234004', true, NOW(), NOW()),
('019391a0-0003-7000-8000-000000000005', 'DOC-005', 'Dr. Hoang Van E', 'Dermatologist', '019391a0-0001-7000-8000-000000000005', 'hoangvane@hospital.com', '0901234005', true, NOW(), NOW()),
('019391a0-0003-7000-8000-000000000006', 'DOC-006', 'Dr. Vu Thi F', 'General Physician', '019391a0-0001-7000-8000-000000000001', 'vuthif@hospital.com', '0901234006', true, NOW(), NOW());

-- ===========================================
-- Doctor-Specialty Mapping
-- ===========================================
INSERT INTO doctor_specialties (doctor_id, specialty_id, is_primary, years_experience, created_at) VALUES
('019391a0-0003-7000-8000-000000000001', '019391a0-0002-7000-8000-000000000001', true, 15, NOW()),
('019391a0-0003-7000-8000-000000000002', '019391a0-0002-7000-8000-000000000002', true, 12, NOW()),
('019391a0-0003-7000-8000-000000000003', '019391a0-0002-7000-8000-000000000003', true, 10, NOW()),
('019391a0-0003-7000-8000-000000000004', '019391a0-0002-7000-8000-000000000004', true, 8, NOW()),
('019391a0-0003-7000-8000-000000000005', '019391a0-0002-7000-8000-000000000005', true, 7, NOW()),
('019391a0-0003-7000-8000-000000000006', '019391a0-0002-7000-8000-000000000001', true, 5, NOW());

-- ===========================================
-- Patients
-- ===========================================
INSERT INTO patients (id, patient_code, full_name, date_of_birth, gender, phone, email, address, insurance_number, is_active, created_at, updated_at) VALUES
('019391a0-0004-7000-8000-000000000001', 'PAT-001', 'Nguyen Minh Tuan', '1990-05-15', 'MALE', '0912345001', 'tuannm@email.com', '123 Le Loi, District 1, HCMC', 'INS-001-2024', true, NOW(), NOW()),
('019391a0-0004-7000-8000-000000000002', 'PAT-002', 'Tran Thi Lan', '1985-08-20', 'FEMALE', '0912345002', 'lantt@email.com', '456 Nguyen Hue, District 1, HCMC', 'INS-002-2024', true, NOW(), NOW()),
('019391a0-0004-7000-8000-000000000003', 'PAT-003', 'Le Hoang Nam', '1978-12-01', 'MALE', '0912345003', 'namlh@email.com', '789 Tran Hung Dao, District 5, HCMC', 'INS-003-2024', true, NOW(), NOW()),
('019391a0-0004-7000-8000-000000000004', 'PAT-004', 'Pham Ngoc Anh', '1995-03-10', 'FEMALE', '0912345004', 'anhpn@email.com', '101 CMT8, District 3, HCMC', NULL, true, NOW(), NOW()),
('019391a0-0004-7000-8000-000000000005', 'PAT-005', 'Vo Van Hung', '2010-07-25', 'MALE', '0912345005', 'hungvv.parent@email.com', '202 Ly Tu Trong, District 1, HCMC', 'INS-005-2024', true, NOW(), NOW());

-- ===========================================
-- Locations
-- ===========================================
INSERT INTO locations (id, code, name, location_type, building, floor, room_number, department_id, capacity, is_active, created_at, updated_at) VALUES
('019391a0-0005-7000-8000-000000000001', 'LOC-REC-01', 'Main Reception', 'RECEPTION', 'Building A', 'G', 'R001', NULL, 5, true, NOW(), NOW()),
('019391a0-0005-7000-8000-000000000002', 'LOC-VIT-01', 'Vital Signs Room 1', 'VITAL_ROOM', 'Building A', '1', 'V101', NULL, 3, true, NOW(), NOW()),
('019391a0-0005-7000-8000-000000000003', 'LOC-EXA-01', 'Exam Room 101', 'EXAM_ROOM', 'Building A', '2', 'E101', '019391a0-0001-7000-8000-000000000001', 1, true, NOW(), NOW()),
('019391a0-0005-7000-8000-000000000004', 'LOC-EXA-02', 'Exam Room 102', 'EXAM_ROOM', 'Building A', '2', 'E102', '019391a0-0001-7000-8000-000000000001', 1, true, NOW(), NOW()),
('019391a0-0005-7000-8000-000000000005', 'LOC-LAB-01', 'Laboratory', 'LAB', 'Building B', '1', 'L001', NULL, 10, true, NOW(), NOW()),
('019391a0-0005-7000-8000-000000000006', 'LOC-IMG-01', 'Imaging Center', 'IMAGING', 'Building B', '2', 'I001', NULL, 5, true, NOW(), NOW()),
('019391a0-0005-7000-8000-000000000007', 'LOC-PHA-01', 'Pharmacy', 'PHARMACY', 'Building A', 'G', 'P001', NULL, 8, true, NOW(), NOW()),
('019391a0-0005-7000-8000-000000000008', 'LOC-CAS-01', 'Cashier', 'CASHIER', 'Building A', 'G', 'C001', NULL, 4, true, NOW(), NOW());

-- ===========================================
-- Symptoms
-- ===========================================
INSERT INTO symptoms (id, code, name, description, category, severity_level, is_active, created_at, updated_at) VALUES
('019391a0-0006-7000-8000-000000000001', 'SYM-FEVER', 'Fever', 'Body temperature above 38C', 'GENERAL', 2, true, NOW(), NOW()),
('019391a0-0006-7000-8000-000000000002', 'SYM-HEADACHE', 'Headache', 'Pain in head or neck region', 'GENERAL', 1, true, NOW(), NOW()),
('019391a0-0006-7000-8000-000000000003', 'SYM-FATIGUE', 'Fatigue', 'Extreme tiredness or exhaustion', 'GENERAL', 1, true, NOW(), NOW()),
('019391a0-0006-7000-8000-000000000004', 'SYM-CHESTPAIN', 'Chest Pain', 'Pain or discomfort in chest area', 'CARDIAC', 3, true, NOW(), NOW()),
('019391a0-0006-7000-8000-000000000005', 'SYM-JOINTPAIN', 'Joint Pain', 'Pain in joints', 'MUSCULOSKELETAL', 2, true, NOW(), NOW()),
('019391a0-0006-7000-8000-000000000006', 'SYM-RASH', 'Skin Rash', 'Visible skin irritation or rash', 'DERMATOLOGY', 1, true, NOW(), NOW()),
('019391a0-0006-7000-8000-000000000007', 'SYM-COUGH', 'Cough', 'Persistent coughing', 'RESPIRATORY', 1, true, NOW(), NOW()),
('019391a0-0006-7000-8000-000000000008', 'SYM-BREATH', 'Shortness of Breath', 'Difficulty breathing', 'RESPIRATORY', 3, true, NOW(), NOW());

-- ===========================================
-- Symptom-Specialty Mapping
-- ===========================================
INSERT INTO symptom_specialties (symptom_id, specialty_id, priority, created_at) VALUES
('019391a0-0006-7000-8000-000000000001', '019391a0-0002-7000-8000-000000000001', 1, NOW()),
('019391a0-0006-7000-8000-000000000002', '019391a0-0002-7000-8000-000000000006', 1, NOW()),
('019391a0-0006-7000-8000-000000000003', '019391a0-0002-7000-8000-000000000001', 1, NOW()),
('019391a0-0006-7000-8000-000000000004', '019391a0-0002-7000-8000-000000000002', 1, NOW()),
('019391a0-0006-7000-8000-000000000005', '019391a0-0002-7000-8000-000000000003', 1, NOW()),
('019391a0-0006-7000-8000-000000000006', '019391a0-0002-7000-8000-000000000005', 1, NOW()),
('019391a0-0006-7000-8000-000000000007', '019391a0-0002-7000-8000-000000000001', 1, NOW()),
('019391a0-0006-7000-8000-000000000008', '019391a0-0002-7000-8000-000000000002', 1, NOW());

-- ===========================================
-- Holidays
-- ===========================================
INSERT INTO holidays (id, holiday_date, name, holiday_type, department_id, is_recurring, created_at, updated_at) VALUES
('019391a0-0007-7000-8000-000000000001', '2025-01-01', 'New Year', 'NATIONAL', NULL, true, NOW(), NOW()),
('019391a0-0007-7000-8000-000000000002', '2025-04-30', 'Reunification Day', 'NATIONAL', NULL, true, NOW(), NOW()),
('019391a0-0007-7000-8000-000000000003', '2025-05-01', 'Labor Day', 'NATIONAL', NULL, true, NOW(), NOW()),
('019391a0-0007-7000-8000-000000000004', '2025-09-02', 'National Day', 'NATIONAL', NULL, true, NOW(), NOW());

-- ===========================================
-- Time Slots (Static sample for next 7 days)
-- ===========================================
-- Doctor 1 - Internal Medicine
INSERT INTO time_slots (id, doctor_id, department_id, slot_date, start_time, end_time, slot_status, capacity, booked_count, version, created_at, updated_at)
SELECT
    gen_random_uuid(),
    '019391a0-0003-7000-8000-000000000001',
    '019391a0-0001-7000-8000-000000000001',
    CURRENT_DATE + day_offset,
    time_slot::TIME,
    (time_slot::TIME + INTERVAL '30 minutes')::TIME,
    'AVAILABLE',
    1, 0, 0, NOW(), NOW()
FROM
    generate_series(1, 7) AS day_offset,
    unnest(ARRAY['08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00',
                 '13:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30']) AS time_slot;

-- Doctor 2 - Cardiology
INSERT INTO time_slots (id, doctor_id, department_id, slot_date, start_time, end_time, slot_status, capacity, booked_count, version, created_at, updated_at)
SELECT
    gen_random_uuid(),
    '019391a0-0003-7000-8000-000000000002',
    '019391a0-0001-7000-8000-000000000002',
    CURRENT_DATE + day_offset,
    time_slot::TIME,
    (time_slot::TIME + INTERVAL '30 minutes')::TIME,
    'AVAILABLE',
    1, 0, 0, NOW(), NOW()
FROM
    generate_series(1, 7) AS day_offset,
    unnest(ARRAY['08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00',
                 '13:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30']) AS time_slot;

-- Doctor 3 - Orthopedics
INSERT INTO time_slots (id, doctor_id, department_id, slot_date, start_time, end_time, slot_status, capacity, booked_count, version, created_at, updated_at)
SELECT
    gen_random_uuid(),
    '019391a0-0003-7000-8000-000000000003',
    '019391a0-0001-7000-8000-000000000003',
    CURRENT_DATE + day_offset,
    time_slot::TIME,
    (time_slot::TIME + INTERVAL '30 minutes')::TIME,
    'AVAILABLE',
    1, 0, 0, NOW(), NOW()
FROM
    generate_series(1, 7) AS day_offset,
    unnest(ARRAY['08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00',
                 '13:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30']) AS time_slot;

-- Doctor 4 - Pediatrics
INSERT INTO time_slots (id, doctor_id, department_id, slot_date, start_time, end_time, slot_status, capacity, booked_count, version, created_at, updated_at)
SELECT
    gen_random_uuid(),
    '019391a0-0003-7000-8000-000000000004',
    '019391a0-0001-7000-8000-000000000004',
    CURRENT_DATE + day_offset,
    time_slot::TIME,
    (time_slot::TIME + INTERVAL '30 minutes')::TIME,
    'AVAILABLE',
    1, 0, 0, NOW(), NOW()
FROM
    generate_series(1, 7) AS day_offset,
    unnest(ARRAY['08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00',
                 '13:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30']) AS time_slot;

-- Doctor 5 - Dermatology
INSERT INTO time_slots (id, doctor_id, department_id, slot_date, start_time, end_time, slot_status, capacity, booked_count, version, created_at, updated_at)
SELECT
    gen_random_uuid(),
    '019391a0-0003-7000-8000-000000000005',
    '019391a0-0001-7000-8000-000000000005',
    CURRENT_DATE + day_offset,
    time_slot::TIME,
    (time_slot::TIME + INTERVAL '30 minutes')::TIME,
    'AVAILABLE',
    1, 0, 0, NOW(), NOW()
FROM
    generate_series(1, 7) AS day_offset,
    unnest(ARRAY['08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00',
                 '13:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30']) AS time_slot;

-- Doctor 6 - Internal Medicine (second doctor)
INSERT INTO time_slots (id, doctor_id, department_id, slot_date, start_time, end_time, slot_status, capacity, booked_count, version, created_at, updated_at)
SELECT
    gen_random_uuid(),
    '019391a0-0003-7000-8000-000000000006',
    '019391a0-0001-7000-8000-000000000001',
    CURRENT_DATE + day_offset,
    time_slot::TIME,
    (time_slot::TIME + INTERVAL '30 minutes')::TIME,
    'AVAILABLE',
    1, 0, 0, NOW(), NOW()
FROM
    generate_series(1, 7) AS day_offset,
    unnest(ARRAY['08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00',
                 '13:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30']) AS time_slot;
