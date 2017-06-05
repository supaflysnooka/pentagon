# Weave

Weave runs an overlay network which helps to work around the 50/100 entry limit on AWS route tables.  It adds a bit of complication and is a hard requirement for pods working successfully. There is a `CONN_LIMIT` environment variable used (defaults to 30) which will cause errors when scaling above 30 instances. Be sure to change this limit if you need more than 30 instances . 
