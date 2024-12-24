package com.project.Fably_Fashion_App.repositories;

import com.project.Fably_Fashion_App.models.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class UserRepository {

    @Autowired
    private final JdbcTemplate jdbcTemplate;


    public UserRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    // Insert a user into the database
    public int createUser(User user) {
        String sql = "INSERT INTO Users (Email, Password, FirstName, LastName, PhoneNumber, Profile_Image_Path) VALUES (?, ?, ?, ?, ?, ?)";
        return jdbcTemplate.update(sql, user.getEmail(), user.getPassword(), user.getFirstName(), user.getLastName(), user.getPhoneNumber(), "");
    }

    public Map<String, Object> getUserByEmail(String email) {
        String sql = "SELECT * FROM Users WHERE Email = ?";
        try {
            return jdbcTemplate.queryForMap(sql, email);
        } catch (EmptyResultDataAccessException e){
            return null;
        }
    }

    public List<Map<String, Object>> getUsers(){
        String sql = "SELECT * FROM Users";
        try {
            return jdbcTemplate.queryForList(sql);
        } catch (EmptyResultDataAccessException e){
            return null;
        }
    }

    public int deleteUser(String email) {
        String sql = "DELETE FROM Users WHERE Email = ?";
        return jdbcTemplate.update(sql, email);
    }

}
