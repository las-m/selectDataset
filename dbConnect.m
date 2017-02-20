conn = database('lithium_log', 'lithium_log', 'RQMPdj5APfhK8R4X', ...
    'com.mysql.jdbc.Driver', 'jdbc:mysql://134.100.111.111:3306/lithium_log')

result = exec(conn, 'SELECT * FROM `experiment_log`');

result = fetch(result)
close(conn)