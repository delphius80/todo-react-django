from rest_framework import serializers
from .models import ToDo
from django.contrib.auth.models import User

class ToDoSerializer(serializers.ModelSerializer):
    class Meta:
        model = ToDo
        fields = ['id', 'title', 'description', 'completed', 'created_at']

class UserSerializer(serializers.ModelSerializer):
    todos = ToDoSerializer(many=True, read_only=True)

    class Meta:
        model = User
        fields = ['id', 'username', 'todos']
