package com.project.Fably_Fashion_App.services;


import com.project.Fably_Fashion_App.models.User;
import com.project.Fably_Fashion_App.repositories.UserRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;


    public String login(User user, HttpSession session) {
        Map<String, Object> map = userRepository.getUserByEmail(user.getEmail());
        if (map==null){
            return "Not Exist";
        }
        boolean correctPassword = PasswordHasher.checkPassword(user.getPassword(), map.get("password").toString());
        if (correctPassword) {
            session.setAttribute("user", user);
            return "Valid";
        }else{
            return "Invalid";
        }
    }

    public String register(User user) {
        user.setPassword(PasswordHasher.hash(user.getPassword()));
        if(userRepository.getUserByEmail(user.getEmail())!=null){
            return "User exists";
        }else {
            userRepository.createUser(user);
            return "User Registered";
        }
    }

    public String deleteUser(User user, HttpSession session) {
        Map<String, Object> map = userRepository.getUserByEmail(user.getEmail());
        if (!PasswordHasher.checkPassword(user.getPassword(), map.get("password").toString())) {
            return "Invalid Password";
        }
        int success = userRepository.deleteUser(user.getEmail());
        if(success>=1){
            session.invalidate();
            return "User Deleted";
        }else {
            return "Failed";
        }
    }

}
