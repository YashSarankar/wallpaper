import React, { useState, useEffect } from 'react';
import axios from 'axios';
import {
    Upload,
    Image as ImageIcon,
    Trash2,
    LayoutDashboard,
    LogOut,
    Plus,
    RefreshCw,
    Search,
    CheckCircle2,
    AlertCircle
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://192.168.29.105:5000/api/wallpapers';

const Dashboard = () => {
    const [wallpapers, setWallpapers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [isUploading, setIsUploading] = useState(false);
    const [searchTerm, setSearchTerm] = useState('');
    const [uploadProgress, setUploadProgress] = useState(0);
    const [dragActive, setDragActive] = useState(false);

    // Form State
    const [title, setTitle] = useState('');
    const [category, setCategory] = useState('Nature');
    const [selectedFile, setSelectedFile] = useState(null);
    const [previewUrl, setPreviewUrl] = useState(null);
    const [message, setMessage] = useState(null);

    const categories = ['Nature', 'Space', 'Game', 'Anime', 'Animal', 'Abstract'];

    useEffect(() => {
        fetchWallpapers();
    }, []);

    const fetchWallpapers = async () => {
        try {
            setLoading(true);
            const res = await axios.get(API_BASE_URL);
            setWallpapers(res.data);
        } catch (err) {
            console.error('Failed to fetch:', err);
        } finally {
            setLoading(false);
        }
    };

    const filteredWallpapers = wallpapers.filter(wp =>
        wp.title?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        wp.category?.toLowerCase().includes(searchTerm.toLowerCase())
    );

    const handleDrag = (e) => {
        e.preventDefault();
        e.stopPropagation();
        if (e.type === "dragenter" || e.type === "dragover") {
            setDragActive(true);
        } else if (e.type === "dragleave") {
            setDragActive(false);
        }
    };

    const handleDrop = (e) => {
        e.preventDefault();
        e.stopPropagation();
        setDragActive(false);
        if (e.dataTransfer.files && e.dataTransfer.files[0]) {
            handleFile(e.dataTransfer.files[0]);
        }
    };

    const handleFile = (file) => {
        if (file && file.type.startsWith('image/')) {
            setSelectedFile(file);
            setPreviewUrl(URL.createObjectURL(file));
        }
    };

    const handleUpload = async (e) => {
        e.preventDefault();
        if (!selectedFile) return;

        const formData = new FormData();
        formData.append('title', title || 'Untitled');
        formData.append('category', category);
        formData.append('image', selectedFile);

        setIsUploading(true);
        setUploadProgress(0);

        try {
            const res = await axios.post(API_BASE_URL, formData, {
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
        } finally {
            setIsUploading(false);
        }
    };

    const resetForm = () => {
        setTitle('');
        setCategory('Nature');
        setSelectedFile(null);
        setPreviewUrl(null);
        setTimeout(() => setMessage(null), 3000);
    };

    const handleDelete = async (id) => {
        if (!window.confirm('Are you sure you want to delete this wallpaper?')) return;

        try {
            await axios.delete(`${API_BASE_URL}/${id}`);
            setMessage({ type: 'success', text: 'Wallpaper deleted' });
            fetchWallpapers();
        } catch (err) {
            setMessage({ type: 'error', text: 'Delete failed' });
        }
    };

    return (
        <div className="min-h-screen p-4 md:p-8 max-w-[1400px] mx-auto">
            {/* Header */}
            <div className="flex justify-between items-center mb-10">
                <div>
                    <h1 className="text-3xl font-extrabold gradient-text uppercase tracking-tighter">WallArt Admin</h1>
                    <p className="text-white/40 text-sm">Manage your premium wallpaper collection</p>
                </div>
                <button className="glass p-3 rounded-full hover:bg-white/10 transition-colors">
                    <LogOut size={20} className="text-white/60" />
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
                            <div
                                className={`relative h-64 border-2 border-dashed rounded-2xl transition-all flex flex-center items-center justify-center overflow-hidden
                  ${dragActive ? 'border-indigo-500 bg-indigo-500/10' : 'border-white/10 bg-white/5'}
                  ${previewUrl ? 'border-none' : ''}`}
                                onDragEnter={handleDrag}
                                onDragLeave={handleDrag}
                                onDragOver={handleDrag}
                                onDrop={handleDrop}
                            >
                                {previewUrl ? (
                                    <>
                                        <img src={previewUrl} alt="Preview" className="w-full h-full object-cover" />
                                        <button
                                            onClick={() => setPreviewUrl(null)}
                                            className="absolute top-2 right-2 bg-black/50 p-2 rounded-full hover:bg-black/80"
                                        >
                                            <Trash2 size={16} />
                                        </button>
                                    </>
                                ) : (
                                    <label className="cursor-pointer text-center p-6">
                                        <input type="file" className="hidden" onChange={(e) => handleFile(e.target.files[0])} accept="image/*" />
                                        <Upload size={40} className="mx-auto mb-4 text-white/20" />
                                        <p className="text-white/60 font-medium">Drag & Drop or click to browse</p>
                                        <p className="text-white/30 text-xs mt-2">Support: JPG, PNG, WEBP (Max 10MB)</p>
                                    </label>
                                )}
                            </div>

                            <div>
                                <label className="text-xs uppercase font-bold text-white/40 block mb-2 px-1">Title</label>
                                <input
                                    type="text"
                                    placeholder="Enter wallpaper title..."
                                    value={title}
                                    onChange={(e) => setTitle(e.target.value)}
                                />
                            </div>

                            <div>
                                <label className="text-xs uppercase font-bold text-white/40 block mb-2 px-1">Category</label>
                                <select value={category} onChange={(e) => setCategory(e.target.value)}>
                                    {categories.map(cat => <option key={cat} value={cat}>{cat}</option>)}
                                </select>
                            </div>

                            <button
                                type="submit"
                                className="primary-btn w-full flex items-center justify-center gap-2 mt-4"
                                disabled={!selectedFile || isUploading}
                            >
                                {isUploading ? (
                                    <>
                                        <RefreshCw size={18} className="animate-spin" />
                                        Uploading {uploadProgress}%
                                    </>
                                ) : (
                                    <>
                                        <Upload size={18} />
                                        Push to Production
                                    </>
                                )}
                            </button>
                        </form>

                        <AnimatePresence>
                            {message && (
                                <motion.div
                                    initial={{ opacity: 0, y: 10 }}
                                    animate={{ opacity: 1, y: 0 }}
                                    exit={{ opacity: 0 }}
                                    className={`mt-4 p-3 rounded-xl flex items-center gap-2 text-sm ${message.type === 'success' ? 'bg-green-500/10 text-green-400' : 'bg-red-500/10 text-red-400'}`}
                                >
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
                            <div className="flex items-center gap-4">
                                <h2 className="text-xl font-bold flex items-center gap-2">
                                    <ImageIcon size={20} className="text-purple-400" />
                                    Live Gallery
                                </h2>
                            </div>
                            <div className="relative w-full sm:w-64">
                                <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-white/20" />
                                <input
                                    type="text"
                                    placeholder="Search title or category..."
                                    className="pl-10 text-sm py-2"
                                    value={searchTerm}
                                    onChange={(e) => setSearchTerm(e.target.value)}
                                />
                            </div>
                        </div>

                        {loading ? (
                            <div className="flex flex-col items-center justify-center h-[400px] text-white/20">
                                <RefreshCw size={40} className="animate-spin mb-4" />
                                <p>Syncing gallery...</p>
                            </div>
                        ) : (
                            <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-4 gap-4">
                                {filteredWallpapers.map((wp) => (
                                    <motion.div
                                        layout
                                        initial={{ opacity: 0 }}
                                        animate={{ opacity: 1 }}
                                        key={wp._id}
                                        className="group glass rounded-2xl overflow-hidden aspect-[3/4] relative"
                                    >
                                        <img
                                            src={wp.imageUrl.low || wp.imageUrl.original}
                                            alt=""
                                            className="w-full h-full object-cover opacity-60 group-hover:opacity-100 transition-opacity duration-500"
                                        />
                                        <div className="absolute inset-x-0 bottom-0 p-3 bg-gradient-to-t from-black/80 to-transparent">
                                            <p className="text-xs font-bold truncate">{wp.title}</p>
                                            <p className="text-[10px] text-white/40 uppercase tracking-widest">{wp.category}</p>
                                        </div>
                                        {/* Actions on hover */}
                                        <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-2">
                                            {/* Delete button */}
                                            <button
                                                onClick={() => handleDelete(wp._id)}
                                                className="bg-red-500/20 p-3 rounded-full hover:bg-red-500/80 transition-all text-red-100"
                                            >
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

export default Dashboard;
