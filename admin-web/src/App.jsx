import React, { useState, useEffect } from 'react';
import axios from 'axios';
import {
    Upload,
    Image as ImageIcon,
    Trash2,
    LayoutDashboard,
    Plus,
    RefreshCw,
    Search,
    CheckCircle2,
    AlertCircle,
    Lock,
    LogOut,
    User
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

// Robust URL management
const getBaseUrl = () => {
    let url = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';
    url = url.replace(/\/$/, '');
    if (url.endsWith('/wallpapers')) {
        url = url.replace('/wallpapers', '');
    }
    return url;
};

const BASE_API = getBaseUrl();
const API_BASE_URL = `${BASE_API}/wallpapers`;
const LOGIN_URL = `${BASE_API}/auth/login`;

// Axios Interceptor for Auth
axios.interceptors.request.use(
    (config) => {
        const token = localStorage.getItem('adminToken');
        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
    },
    (error) => Promise.reject(error)
);

const Login = ({ onLogin }) => {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError('');
        try {
            const res = await axios.post(LOGIN_URL, { username, password });
            localStorage.setItem('adminToken', res.data.token);
            onLogin(res.data.token);
        } catch (err) {
            setError(err.response?.data?.msg || 'Invalid credentials or server error');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center p-4">
            <motion.div
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                className="glass p-8 rounded-3xl w-full max-w-md space-y-6"
            >
                <div className="text-center space-y-2">
                    <h1 className="text-3xl font-extrabold gradient-text uppercase tracking-tighter">Amozea Admin</h1>
                    <p className="text-white/40 text-sm">Sign in to manage your collection</p>
                </div>

                <form onSubmit={handleSubmit} className="space-y-4">
                    <div className="space-y-2">
                        <label className="text-xs uppercase font-bold text-white/40 flex items-center gap-2 px-1">
                            <User size={14} /> Username
                        </label>
                        <input
                            type="text"
                            placeholder="Enter username"
                            value={username}
                            onChange={(e) => setUsername(e.target.value)}
                            required
                        />
                    </div>
                    <div className="space-y-2">
                        <label className="text-xs uppercase font-bold text-white/40 flex items-center gap-2 px-1">
                            <Lock size={14} /> Password
                        </label>
                        <input
                            type="password"
                            placeholder="Enter password"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            required
                        />
                    </div>

                    {error && (
                        <div className="bg-red-500/10 text-red-400 p-3 rounded-xl text-xs flex items-center gap-2">
                            <AlertCircle size={14} /> {error}
                        </div>
                    )}

                    <button
                        type="submit"
                        disabled={loading}
                        className="primary-btn w-full flex items-center justify-center gap-2"
                    >
                        {loading ? <RefreshCw className="animate-spin" size={18} /> : 'Access Dashboard'}
                    </button>
                </form>
            </motion.div>
        </div>
    );
};

const Dashboard = ({ onLogout }) => {
    const [wallpapers, setWallpapers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [isUploading, setIsUploading] = useState(false);
    const [searchTerm, setSearchTerm] = useState('');
    const [filterCategory, setFilterCategory] = useState('All');
    const [uploadProgress, setUploadProgress] = useState(0);
    const [dragActive, setDragActive] = useState(false);
    const [selectedIds, setSelectedIds] = useState([]);
    const [isBulkDeleting, setIsBulkDeleting] = useState(false);

    // Form State
    const [title, setTitle] = useState('');
    const [category, setCategory] = useState('Nature');
    const [type, setType] = useState('static');
    const [selectedFile, setSelectedFile] = useState(null); // This is the image/preview
    const [videoFile, setVideoFile] = useState(null);
    const [previewUrl, setPreviewUrl] = useState(null);
    const [videoPreviewUrl, setVideoPreviewUrl] = useState(null);
    const [message, setMessage] = useState(null);

    const categories = [
        'Amoled', 'Nature', 'Stock', 'Black', 'Cars & Bike', 'Model',
        'Fitness', 'God', 'Festival', 'Abstract', 'Anime', 'Romantic Vibe',
        'Fantasy', 'Top Wallpaper', 'Superhero', 'Travel', 'Movies', 'Food',
        'Text', 'Game'
    ];

    const categoryCounts = wallpapers.reduce((acc, wp) => {
        acc[wp.category] = (acc[wp.category] || 0) + 1;
        return acc;
    }, {});

    const handleFile = (file) => {
        if (!file) return;
        if (file.type.startsWith('image/')) {
            if (file.size > 10 * 1024 * 1024) {
                setMessage({ type: 'error', text: 'Image size must be less than 10MB' });
                return;
            }
            setSelectedFile(file);
            const reader = new FileReader();
            reader.onloadend = () => {
                setPreviewUrl(reader.result);
            };
            reader.readAsDataURL(file);
        } else if (file.type.startsWith('video/')) {
            if (type !== 'animated') {
                setMessage({ type: 'error', text: 'Change type to "Animated" to upload videos' });
                return;
            }
            if (file.size > 50 * 1024 * 1024) {
                setMessage({ type: 'error', text: 'Video size must be less than 50MB' });
                return;
            }
            setVideoFile(file);
            const url = URL.createObjectURL(file);
            setVideoPreviewUrl(url);
        } else {
            setMessage({ type: 'error', text: 'Unsupported file type' });
        }
    };

    useEffect(() => {
        fetchWallpapers();
    }, []);

    const fetchWallpapers = async () => {
        try {
            setLoading(true);
            const res = await axios.get(API_BASE_URL);
            setWallpapers(res.data);
            setSelectedIds([]);
        } catch (err) {
            console.error('Failed to fetch:', err);
            if (err.response?.status === 401) {
                onLogout();
            }
        } finally {
            setLoading(false);
        }
    };

    const filteredWallpapers = wallpapers.filter(wp => {
        const matchesSearch = wp.title?.toLowerCase().includes(searchTerm.toLowerCase()) ||
            wp.category?.toLowerCase().includes(searchTerm.toLowerCase());
        const matchesCategory = filterCategory === 'All' || wp.category === filterCategory;
        return matchesSearch && matchesCategory;
    });

    const handleDrag = (e) => {
        e.preventDefault(); e.stopPropagation();
        if (e.type === "dragenter" || e.type === "dragover") setDragActive(true);
        else if (e.type === "dragleave") setDragActive(false);
    };

    const handleDrop = (e) => {
        e.preventDefault(); e.stopPropagation();
        setDragActive(false);
        if (e.dataTransfer.files && e.dataTransfer.files[0]) handleFile(e.dataTransfer.files[0]);
    };

    const toggleSelection = (id) => {
        setSelectedIds(prev =>
            prev.includes(id) ? prev.filter(i => i !== id) : [...prev, id]
        );
    };

    const handleBulkDelete = async () => {
        if (!selectedIds.length) return;
        if (!window.confirm(`Delete ${selectedIds.length} wallpapers from DB and Storage?`)) return;

        setIsBulkDeleting(true);
        try {
            await axios.post(`${API_BASE_URL}/bulk-delete`, { ids: selectedIds });
            setMessage({ type: 'success', text: `${selectedIds.length} wallpapers deleted` });
            fetchWallpapers();
        } catch (err) {
            setMessage({ type: 'error', text: 'Bulk delete failed: ' + (err.response?.data?.msg || err.message) });
            if (err.response?.status === 401) onLogout();
        } finally {
            setIsBulkDeleting(false);
        }
    };

    const handleUpload = async (e) => {
        e.preventDefault();
        if (!selectedFile) {
            setMessage({ type: 'error', text: 'Preview image is required' });
            return;
        }
        if (type === 'animated' && !videoFile) {
            setMessage({ type: 'error', text: 'Video file is required for animated wallpapers' });
            return;
        }

        const formData = new FormData();
        formData.append('title', title || 'Untitled');
        formData.append('category', category);
        formData.append('type', type);
        formData.append('image', selectedFile);
        if (videoFile) formData.append('video', videoFile);

        setIsUploading(true);
        setUploadProgress(0);

        try {
            await axios.post(API_BASE_URL, formData, {
                onUploadProgress: (progressEvent) => {
                    const progress = Math.round((progressEvent.loaded * 100) / progressEvent.total);
                    setUploadProgress(progress);
                }
            });

            setMessage({ type: 'success', text: 'Wallpaper uploaded successfully!' });
            resetForm();
            fetchWallpapers();
        } catch (err) {
            setMessage({ type: 'error', text: 'Upload failed: ' + (err.response?.data?.msg || err.message) });
            if (err.response?.status === 401) onLogout();
        } finally {
            setIsUploading(false);
        }
    };

    const resetForm = () => {
        setTitle('');
        setCategory('Nature');
        setType('static');
        setSelectedFile(null);
        setVideoFile(null);
        setPreviewUrl(null);
        setVideoPreviewUrl(null);
        setTimeout(() => setMessage(null), 3000);
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Delete this wallpaper?')) return;
        try {
            await axios.delete(`${API_BASE_URL}/${id}`);
            setMessage({ type: 'success', text: 'Wallpaper deleted' });
            fetchWallpapers();
        } catch (err) {
            setMessage({ type: 'error', text: 'Delete failed: ' + (err.response?.data?.msg || err.message) });
            if (err.response?.status === 401) onLogout();
        }
    };

    return (
        <div className="min-h-screen p-4 md:p-8 max-w-[1400px] mx-auto">
            {/* Header */}
            <div className="flex justify-between items-center mb-10">
                <div>
                    <h1 className="text-3xl font-extrabold gradient-text uppercase tracking-tighter">Amozea Admin</h1>
                    <p className="text-white/40 text-sm">Manage your premium AMOLED & 4K collection</p>
                </div>
                <button
                    onClick={onLogout}
                    className="glass px-4 py-2 rounded-xl text-xs font-bold uppercase tracking-widest text-white/60 hover:text-white hover:bg-white/10 transition-all flex items-center gap-2"
                >
                    <LogOut size={14} /> Logout
                </button>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-12 gap-8">
                {/* Upload Section */}
                <div className="lg:col-span-4 space-y-6">
                    <div className="glass p-6 rounded-3xl relative overflow-hidden">
                        <h2 className="text-xl font-bold mb-6 flex items-center gap-2">
                            <Plus size={20} className="text-indigo-400" /> Upload New
                        </h2>

                        <form onSubmit={handleUpload} className="space-y-4">
                            <div className="grid grid-cols-2 gap-3">
                                <button
                                    type="button"
                                    onClick={() => setType('static')}
                                    className={`px-4 py-2 rounded-xl text-xs font-bold uppercase transition-all ${type === 'static' ? 'bg-indigo-500 text-white' : 'bg-white/5 text-white/40 hover:bg-white/10'}`}
                                >
                                    Static
                                </button>
                                <button
                                    type="button"
                                    onClick={() => setType('animated')}
                                    className={`px-4 py-2 rounded-xl text-xs font-bold uppercase transition-all ${type === 'animated' ? 'bg-indigo-500 text-white' : 'bg-white/5 text-white/40 hover:bg-white/10'}`}
                                >
                                    Animated
                                </button>
                            </div>

                            <div className="space-y-4">
                                <div>
                                    <label className="text-xs uppercase font-bold text-white/40 block mb-2 px-1">
                                        {type === 'animated' ? 'Preview Image' : 'Wallpaper Image'}
                                    </label>
                                    <div
                                        className={`relative h-48 border-2 border-dashed rounded-2xl transition-all flex flex-center items-center justify-center overflow-hidden
                                        ${dragActive ? 'border-indigo-500 bg-indigo-500/10' : 'border-white/10 bg-white/5'}
                                        ${previewUrl ? 'border-none' : ''}`}
                                        onDragEnter={handleDrag} onDragLeave={handleDrag} onDragOver={handleDrag} onDrop={handleDrop}
                                    >
                                        {previewUrl ? (
                                            <>
                                                <img src={previewUrl} alt="Preview" className="w-full h-full object-cover" />
                                                <button type="button" onClick={() => { setSelectedFile(null); setPreviewUrl(null); }} className="absolute top-2 right-2 bg-black/50 p-2 rounded-full hover:bg-black/80">
                                                    <Trash2 size={16} />
                                                </button>
                                            </>
                                        ) : (
                                            <label className="cursor-pointer text-center p-6 w-full">
                                                <input type="file" className="hidden" onChange={(e) => handleFile(e.target.files[0])} accept="image/*" />
                                                <ImageIcon size={32} className="mx-auto mb-4 text-white/20" />
                                                <p className="text-white/60 text-sm font-medium">Add Image</p>
                                                <p className="text-white/30 text-[10px] mt-1">JPG, PNG, WEBP</p>
                                            </label>
                                        )}
                                    </div>
                                </div>

                                {type === 'animated' && (
                                    <motion.div initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }}>
                                        <label className="text-xs uppercase font-bold text-white/40 block mb-2 px-1">Video File</label>
                                        <div
                                            className={`relative h-48 border-2 border-dashed rounded-2xl transition-all flex flex-center items-center justify-center overflow-hidden
                                            ${videoPreviewUrl ? 'border-none' : 'border-white/10 bg-white/5'}`}
                                        >
                                            {videoPreviewUrl ? (
                                                <>
                                                    <video src={videoPreviewUrl} autoPlay muted loop className="w-full h-full object-cover" />
                                                    <button type="button" onClick={() => { setVideoFile(null); setVideoPreviewUrl(null); }} className="absolute top-2 right-2 bg-black/50 p-2 rounded-full hover:bg-black/80">
                                                        <Trash2 size={16} />
                                                    </button>
                                                </>
                                            ) : (
                                                <label className="cursor-pointer text-center p-6 w-full">
                                                    <input type="file" className="hidden" onChange={(e) => handleFile(e.target.files[0])} accept="video/*" />
                                                    <Upload size={32} className="mx-auto mb-4 text-white/20" />
                                                    <p className="text-white/60 text-sm font-medium">Add Video</p>
                                                    <p className="text-white/30 text-[10px] mt-1">MP4, MOV (Max 50MB)</p>
                                                </label>
                                            )}
                                        </div>
                                    </motion.div>
                                )}
                            </div>

                            <div>
                                <label className="text-xs uppercase font-bold text-white/40 block mb-2 px-1">Title</label>
                                <input type="text" placeholder="Enter wallpaper title..." value={title} onChange={(e) => setTitle(e.target.value)} />
                            </div>

                            <div>
                                <label className="text-xs uppercase font-bold text-white/40 block mb-2 px-1">Category</label>
                                <select value={category} onChange={(e) => setCategory(e.target.value)}>
                                    {categories.map(cat => (
                                        <option key={cat} value={cat}>
                                            {cat} ({categoryCounts[cat] || 0})
                                        </option>
                                    ))}
                                </select>
                            </div>

                            <button type="submit" className="primary-btn w-full flex items-center justify-center gap-2 mt-4" disabled={!selectedFile || (type === 'animated' && !videoFile) || isUploading}>
                                {isUploading ? <><RefreshCw size={18} className="animate-spin" /> Uploading {uploadProgress}%</> : <><Upload size={18} /> Push to Production</>}
                            </button>
                        </form>

                        <AnimatePresence>
                            {message && (
                                <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0 }}
                                    className={`mt-4 p-3 rounded-xl flex items-center gap-2 text-sm ${message.type === 'success' ? 'bg-green-500/10 text-green-400' : 'bg-red-500/10 text-red-400'}`}>
                                    {message.type === 'success' ? <CheckCircle2 size={16} /> : <AlertCircle size={16} />}
                                    {message.text}
                                </motion.div>
                            )}
                        </AnimatePresence>
                    </div>
                </div>

                {/* List Section */}
                <div className="lg:col-span-8 space-y-6">
                    <div className="glass p-6 rounded-3xl min-h-[600px]">
                        <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-8">
                            <div className="flex flex-col gap-2">
                                <div className="flex items-center gap-4">
                                    <h2 className="text-xl font-bold flex items-center gap-2">
                                        <ImageIcon size={20} className="text-purple-400" />
                                        Live Gallery
                                    </h2>
                                    {selectedIds.length > 0 && (
                                        <button onClick={handleBulkDelete} disabled={isBulkDeleting} className="bg-red-500/20 text-red-100 px-4 py-1.5 rounded-full text-xs font-bold uppercase tracking-widest flex items-center gap-2 hover:bg-red-500/80 transition-all">
                                            {isBulkDeleting ? <RefreshCw className="animate-spin" size={14} /> : <Trash2 size={14} />}
                                            Delete {selectedIds.length} Items
                                        </button>
                                    )}
                                </div>
                            </div>

                            <div className="flex flex-col sm:flex-row items-center gap-3 w-full sm:w-auto">
                                <select value={filterCategory} onChange={(e) => setFilterCategory(e.target.value)} className="text-xs font-bold py-2 w-full sm:w-40 border-none bg-indigo-500/10 text-indigo-300 rounded-xl cursor-pointer hover:bg-indigo-500/20 transition-all">
                                    <option value="All">All Categories ({wallpapers.length})</option>
                                    {categories.map(cat => (
                                        <option key={cat} value={cat}>
                                            {cat} ({categoryCounts[cat] || 0})
                                        </option>
                                    ))}
                                </select>
                                <div className="relative w-full sm:w-64">
                                    <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-white/20" />
                                    <input type="text" placeholder="Search..." className="pl-10 text-sm py-2" value={searchTerm} onChange={(e) => setSearchTerm(e.target.value)} />
                                </div>
                            </div>
                        </div>

                        {loading ? (
                            <div className="flex flex-col items-center justify-center h-[400px] text-white/20">
                                <RefreshCw size={40} className="animate-spin mb-4" />
                                <p>Syncing gallery...</p>
                            </div>
                        ) : (
                            <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 xl:grid-cols-6 gap-3">
                                {filteredWallpapers.map((wp) => (
                                    <motion.div layout initial={{ opacity: 0 }} animate={{ opacity: 1 }} key={wp._id} onClick={() => toggleSelection(wp._id)}
                                        className={`group glass rounded-xl overflow-hidden aspect-square relative cursor-pointer transition-all duration-300 ${selectedIds.includes(wp._id) ? 'ring-2 ring-indigo-500 ring-offset-4 ring-offset-[#0c0c0e] scale-[0.9]' : ''}`}
                                    >
                                        <img src={wp.imageUrl.low || wp.imageUrl.original} alt="" className={`w-full h-full object-cover transition-all duration-500 ${selectedIds.includes(wp._id) ? 'opacity-100 scale-110' : 'opacity-60 group-hover:opacity-100'}`} />

                                        {wp.type === 'animated' && (
                                            <div className="absolute top-2 left-2 bg-indigo-500 text-[8px] font-black uppercase tracking-tighter text-white px-2 py-0.5 rounded-full shadow-lg z-10">
                                                Live
                                            </div>
                                        )}

                                        {selectedIds.includes(wp._id) && <div className="absolute top-2 right-2 bg-indigo-500 text-white rounded-full p-1 shadow-lg z-10"><CheckCircle2 size={16} /></div>}
                                        <div className="absolute inset-x-0 bottom-0 p-3 bg-gradient-to-t from-black/80 to-transparent">
                                            <p className="text-xs font-bold truncate">{wp.title}</p>
                                            <p className="text-[10px] text-white/40 uppercase tracking-widest">{wp.category}</p>
                                        </div>
                                        <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-2">
                                            <button onClick={(e) => { e.stopPropagation(); handleDelete(wp._id); }} className="bg-red-500/20 p-3 rounded-full hover:bg-red-500/80 transition-all text-red-100">
                                                <Trash2 size={18} />
                                            </button>
                                        </div>
                                    </motion.div>
                                ))}
                            </div>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
};

const App = () => {
    const [isAuthenticated, setIsAuthenticated] = useState(!!localStorage.getItem('adminToken'));

    const handleLogout = () => {
        localStorage.removeItem('adminToken');
        setIsAuthenticated(false);
    };

    return (
        <AnimatePresence mode="wait">
            {!isAuthenticated ? (
                <motion.div
                    key="login"
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    exit={{ opacity: 0, y: -20 }}
                >
                    <Login onLogin={() => setIsAuthenticated(true)} />
                </motion.div>
            ) : (
                <motion.div
                    key="dashboard"
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    exit={{ opacity: 0 }}
                >
                    <Dashboard onLogout={handleLogout} />
                </motion.div>
            )}
        </AnimatePresence>
    );
};

export default App;
