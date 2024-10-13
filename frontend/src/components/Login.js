// src/components/Login.js
import React, { useState } from 'react';
import api from '../services/api';
import { useNavigate, Link } from 'react-router-dom';
import './Login.css';

const Login = ({ onLogin }) => {
    const navigate = useNavigate();
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');

    const handleLogin = async (e) => {
        e.preventDefault();
        try {
            const response = await api.post('auth/token/', { username, password });
            localStorage.setItem('access_token', response.data.access);
            localStorage.setItem('refresh_token', response.data.refresh);
            onLogin(); // Обновляем состояние аутентификации
            navigate('/todos');
        } catch (error) {
            console.error('Ошибка при входе:', error);
            alert('Неверные данные для входа');
        }
    };

    return (
        <div className="container">
            <form className="auth-form" onSubmit={handleLogin}>
                <h2>Вход</h2>
                <input 
                    type="text" 
                    placeholder="Имя пользователя" 
                    value={username} 
                    onChange={(e) => setUsername(e.target.value)} 
                    required 
                />
                <input 
                    type="password" 
                    placeholder="Пароль" 
                    value={password} 
                    onChange={(e) => setPassword(e.target.value)} 
                    required 
                />
                <button type="submit">Войти</button>
                <div className="link">
                    Нет аккаунта? <Link to="/register">Зарегистрироваться</Link>
                </div>
            </form>
        </div>
    );
};

export default Login;
