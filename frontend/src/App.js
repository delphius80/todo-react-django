// src/App.js
import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Route, Routes, Navigate } from 'react-router-dom';
import Login from './components/Login';
import Register from './components/Register';
import ToDoList from './components/ToDoList';
import './App.css'; // Подключение глобальных стилей

const App = () => {
    const [authenticated, setAuthenticated] = useState(false);

    useEffect(() => {
        const token = localStorage.getItem('access_token');
        setAuthenticated(token !== null);
    }, []);

    const handleLogin = () => {
        setAuthenticated(true);
    };

    return (
        <Router>
            <Routes>
                <Route path="/login" element={<Login onLogin={handleLogin} />} />
                <Route path="/register" element={<Register />} />
                <Route 
                    path="/todos" 
                    element={
                        authenticated ? <ToDoList /> : <Navigate to="/login" replace />
                    } 
                />
                <Route path="*" element={<Navigate to="/todos" replace />} />
            </Routes>
        </Router>
    );
};

export default App;
