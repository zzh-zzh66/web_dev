UPDATE t_user SET role = 'ADMIN' WHERE phone = '13812345610';
UPDATE t_user SET role = 'MEMBER' WHERE phone != '13812345610';
SELECT id, name, phone, role FROM t_user;
