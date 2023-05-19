from sqlalchemy.orm import sessionmaker
from scanner import getConfig
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
Base = declarative_base()

def getDb():
    conf = getConfig()
    db_user = conf['database']['user']
    db_host = conf['database']['host']
    db_password = conf['database']['password']
    db_name = conf['database']['name']
    engine = create_engine('mysql+pymysql://' + db_user + ':' + db_password + '@' + db_host + '/' + db_name,
                           pool_recycle=3600)
    Session = sessionmaker(bind=engine)
    return Session()
