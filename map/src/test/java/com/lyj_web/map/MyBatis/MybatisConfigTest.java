package com.lyj_web.map.MyBatis;

import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;

@SpringBootTest
@Slf4j
public class MybatisConfigTest {
    @Autowired
    private SqlSessionFactory sqlSessionFactory;

    @Autowired
    private DataSource dataSource;

    @Test
    public void testDataSource() {
        try (Connection conn = dataSource.getConnection();) {
            log.info("----------------------------------");
            log.info("datasource connection: "+conn);
            log.info("----------------------------------");
        } catch (Exception e) {
            log.error(e.getMessage());
        }
    }

    @Test
    public void testSqlSession() throws SQLException {
        log.info("----------------------------------");
        log.info("sql session factory: "+sqlSessionFactory);
        log.info("----------------------------------");
        try(SqlSession sqlSession = sqlSessionFactory.openSession(true); Connection conn = sqlSession.getConnection();) {
            log.info("----------------------------------");
            log.info("sql session: "+sqlSession);
            log.info("sql session connection"+conn);
            log.info("----------------------------------");
        }catch (Exception e) {
            log.info(e.getMessage());
        }
    }
}
