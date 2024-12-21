package com.project.Fably_Fashion_App.controllers;

import com.project.Fably_Fashion_App.models.User;
import com.project.Fably_Fashion_App.services.UserService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.Objects;

@Controller
@CrossOrigin(origins = "*")
@RequestMapping("/api/user")
public class UserController {

    @Autowired
    private UserService userService;

    @RequestMapping("/login")
    public ResponseEntity<String> login(@RequestBody User user, HttpSession session){
        if(Objects.equals(user.getEmail(), "") || Objects.equals(user.getPassword(), "")){
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Need Email and password");// error 400
        }
        String response = userService.login(user, session);
        if (response=="Not Exist"){
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("No such user exists");// error 404
        } else if(response=="Invalid"){
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid email or password");// error 401
        }
        return ResponseEntity.ok().body("Logged In");// status 200

    }

    @RequestMapping("/logout")
    public ResponseEntity<String> logout(HttpSession session){
        session.invalidate();
        return ResponseEntity.ok("Logged out");// status 200
    }

    @RequestMapping("/delete_user_account")
    public ResponseEntity<String> deleteUserAccount(@RequestBody User user, HttpSession session){
        /*
        * user must be logged in an enter username and password to delete the account
        * */
        if(session.getAttribute("user")==null){
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Not Logged In");// error 401
        }
        String response = userService.deleteUser(user, session);
        if (response=="Invalid Password"){
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Invalid Password");// error 400
        } else if (response=="Failed") {
            return ResponseEntity.internalServerError().body("Failed to delete account");// error 500
        }
        return ResponseEntity.ok().body(response);// status 200

    }

    @RequestMapping("/register")
    public ResponseEntity<String> register(@RequestBody User user, HttpSession session){
        String response = userService.register(user);
        if (response=="User exists" ) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("User exists");// error 409
        } else {
            return ResponseEntity.ok(response);// status 200
        }
    }

}
