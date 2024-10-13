// src/components/ToDoList.js
import React, { useState, useEffect, useCallback } from 'react';
import api from '../services/api';
import ToDoItem from './ToDoItem';
import { useNavigate } from 'react-router-dom';
import './ToDoList.css';

const ToDoList = () => {
    const navigate = useNavigate();
    const [todos, setTodos] = useState([]);
    const [title, setTitle] = useState('');
    const [description, setDescription] = useState('');

    const fetchToDos = useCallback(async () => {
        try {
            const response = await api.get('todos/');
            setTodos(response.data);
        } catch (error) {
            if (error.response && error.response.status === 401) {
                navigate('/login');
            }
        }
    }, [navigate]);

    useEffect(() => {
        fetchToDos();
    }, [fetchToDos]);

    const handleAdd = async (e) => {
        e.preventDefault();
        try {
            const response = await api.post('todos/', { title, description });
            setTodos([...todos, response.data]);
            setTitle('');
            setDescription('');
        } catch (error) {
            alert('Ошибка добавления задачи');
        }
    };

    const handleLogout = () => {
        localStorage.removeItem('access_token');
        localStorage.removeItem('refresh_token');
        navigate('/login');
    };

    return (
        <div className="container">
            <div className="todo-container">
                <button className="logout-button" onClick={handleLogout}>Выйти</button>
                <h2>Ваши задачи</h2>
                <form className="todo-form" onSubmit={handleAdd}>
                    <input 
                        type="text" 
                        placeholder="Заголовок" 
                        value={title} 
                        onChange={(e) => setTitle(e.target.value)} 
                        required 
                    />
                    <input 
                        type="text" 
                        placeholder="Описание" 
                        value={description} 
                        onChange={(e) => setDescription(e.target.value)} 
                    />
                    <button type="submit">Добавить</button>
                </form>
                <ul className="todo-list">
                    {todos.map(todo => (
                        <ToDoItem key={todo.id} todo={todo} onUpdate={fetchToDos} />
                    ))}
                </ul>
            </div>
        </div>
    );
};

export default ToDoList;
