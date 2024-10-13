// src/components/ToDoItem.js
import React, { useState } from 'react';
import api from '../services/api';
import './ToDoItem.css';

const ToDoItem = ({ todo, onUpdate }) => {
    const [isEditing, setIsEditing] = useState(false);
    const [title, setTitle] = useState(todo.title);
    const [description, setDescription] = useState(todo.description);
    const [completed, setCompleted] = useState(todo.completed);

    const handleDelete = async () => {
        try {
            await api.delete(`todos/${todo.id}/`);
            onUpdate();
        } catch (error) {
            alert('Ошибка удаления задачи');
        }
    };

    const handleUpdate = async () => {
        try {
            await api.put(`todos/${todo.id}/`, { title, description, completed });
            setIsEditing(false);
            onUpdate();
        } catch (error) {
            alert('Ошибка обновления задачи');
        }
    };

    return (
        <li className={`todo-item ${completed ? 'completed' : ''}`}>
            {isEditing ? (
                <div>
                    <input 
                        type="text" 
                        value={title} 
                        onChange={(e) => setTitle(e.target.value)} 
                    />
                    <input 
                        type="text" 
                        value={description} 
                        onChange={(e) => setDescription(e.target.value)} 
                    />
                    <label>
                        Завершено:
                        <input 
                            type="checkbox" 
                            checked={completed} 
                            onChange={(e) => setCompleted(e.target.checked)} 
                        />
                    </label>
                    <button className="save-button" onClick={handleUpdate}>Сохранить</button>
                    <button className="cancel-button" onClick={() => setIsEditing(false)}>Отмена</button>
                </div>
            ) : (
                <div>
                    <h3>{todo.title}</h3>
                    <p>{todo.description}</p>
                    <p>Создано: {new Date(todo.created_at).toLocaleString()}</p>
                    <button className="edit-button" onClick={() => setIsEditing(true)}>Редактировать</button>
                    <button className="delete-button" onClick={handleDelete}>Удалить</button>
                </div>
            )}
        </li>
    );
};

export default ToDoItem;
