// I want this to have GET, PUT, POST, DELETE methods for { public: get, post, put, delete, private: get, post, put, delete }
// private will use JSON Web Token (JWT) authentication from the primary server not this one, this one will just verify the token with the primary server an keep a cache of valid tokens for a short time

const public = {
    get: async (url, options = {}) => {
        const response = await fetch(url, {
            method: 'GET',
            ...options
        });
        return response.json();
    },
    post: async (url, body, options = {}) => {
        const requestBody = {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', ...(options.headers || {}) },
            body: JSON.stringify(body),
            ...options
        };
        const response = await fetch(url, requestBody);
        return response.json();
    },
    put: async (url, body, options = {}) => {
        const response = await fetch(url, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json', ...(options.headers || {}) },
            body: JSON.stringify(body),
            ...options
        });
        return response.json();
    },
    delete: async (url, options = {}) => {
        const response = await fetch(url, {
            method: 'DELETE',
            ...options
        });
        return response.json();
    }
};

const private = {
    get: async (url, token, options = {}) => {
        const response = await fetch(url, {
            method: 'GET',
            headers: { 'Authorization': `Bearer ${token}`, ...(options.headers || {}) },
            ...options
        });
        return response.json();
    },
    post: async (url, body, token, options = {}) => {
        const response = await fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}`, ...(options.headers || {}) },
            body: JSON.stringify(body),
            ...options
        });
        return response.json();
    },
    put: async (url, body, token, options = {}) => {
        const response = await fetch(url, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}`, ...(options.headers || {}) },
            body: JSON.stringify    (body),
            ...options
        });
        return response.json();
    },
    delete: async (url, token, options = {}) => {
        const response = await fetch(url, {
            method: 'DELETE',
            headers: { 'Authorization': `Bearer ${token}`, ...(options.headers || {}) },
            ...options
        });
        return response.json();
    }
};

module.exports = {
    public,
    private
};