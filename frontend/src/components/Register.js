// src/components/Register.js
import React, { useState } from 'react';
import api from '../services/api';
import { useNavigate, Link } from 'react-router-dom';
import './Register.css';

const Register = () => {
    const navigate = useNavigate();
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');

    const handleRegister = async (e) => {
        e.preventDefault();
        try {
            await api.post('users/register/', { username, password });
            alert('Регистрация успешна');
            navigate('/login');
        } catch (error) {
            alert('Ошибка регистрации');
        }
    };

    return (
        <div className="container">
            <form className="auth-form" onSubmit={handleRegister}>
                <h2>Регистрация</h2>
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
                <button type="submit">Зарегистрироваться</button>
                <div className="link">
                    Уже есть аккаунт? <Link to="/login">Войти</Link>
                </div>
            </form>
        </div>
    );
};

export default Register;
