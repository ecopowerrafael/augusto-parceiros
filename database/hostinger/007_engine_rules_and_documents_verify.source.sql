-- Verificação posterior somente leitura da Migration 007.
SELECT VERSION() AS mysql_version;
SELECT DATABASE() AS selected_database;
SELECT COUNT(*) AS migration_007_count FROM schema_migrations WHERE name = '007_engine_rules_and_documents.sql';
SELECT COUNT(*) AS new_engine_fields FROM service_form_fields WHERE id IN ('36000000-0000-4000-8000-000000000014', '36000000-0000-4000-8000-000000000015');
SELECT field_key, field_type, is_required, visibility_condition, required_condition, calculation FROM service_form_fields WHERE id IN ('36000000-0000-4000-8000-000000000014', '36000000-0000-4000-8000-000000000015');
SELECT COUNT(*) AS manual_settings_columns FROM information_schema.columns WHERE table_schema = 'u891593158_doc' AND table_name = 'application_settings' AND column_name IN ('manual_whatsapp', 'manual_team_name', 'manual_message_template');
SELECT COUNT(*) AS category_options FROM service_field_options WHERE field_id = '36000000-0000-4000-8000-000000000002' AND option_value IN ('MOTORCYCLE', 'AUTOMOBILE', 'TRUCK', 'BUS', 'OTHER');
SELECT COUNT(*) AS rule_count FROM technical_rules WHERE id IN ('43000000-0000-4000-8000-000000000001', '43000000-0000-4000-8000-000000000007') AND status = 'DRAFT';
SELECT bi.code, sbi.billing_mode, sbi.include_in_total, sbi.visible_to_client, sbi.visible_to_partner FROM service_billing_items sbi JOIN billing_items bi ON bi.id = sbi.billing_item_id WHERE sbi.service_version_id = '33000000-0000-4000-8000-000000000001' AND bi.code IN ('MODIFICATION_REQUEST', 'ITL_CSV_INSPECTION');
SELECT document_code, name, requirement_type FROM service_documents WHERE service_version_id = '33000000-0000-4000-8000-000000000001' ORDER BY display_order;
SELECT COUNT(*) AS expected_documents FROM service_documents WHERE service_version_id = '33000000-0000-4000-8000-000000000001' AND document_code IN ('ENGINE_INVOICE', 'VEHICLE_REGISTRATION', 'OWNER_IDENTIFICATION', 'INSPECTION_REPORT');
SELECT message_key, severity, content FROM service_messages WHERE service_version_id = '33000000-0000-4000-8000-000000000001' ORDER BY display_order;
SELECT manual_whatsapp, manual_team_name, manual_message_template FROM application_settings WHERE id = '55000000-0000-4000-8000-000000000001';
