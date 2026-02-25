import { useState, useEffect, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import styles from './LoginPage.module.css'

export default function LoginPage() {
    const navigate = useNavigate()
    const [step, setStep] = useState(1)
    const [mobile, setMobile] = useState('')
    const [otp, setOtp] = useState(['', '', '', '', '', ''])
    const [seconds, setSeconds] = useState(59)
    const [canResend, setCanResend] = useState(false)
    const [shaking, setShaking] = useState(false)
    const timerRef = useRef(null)
    const otpRefs = useRef([])

    /* ── countdown ─────────────────────────────────────────────── */
    useEffect(() => {
        if (step !== 2) return
        startCountdown()
        return () => clearInterval(timerRef.current)
    }, [step])

    function startCountdown() {
        clearInterval(timerRef.current)
        setSeconds(59)
        setCanResend(false)
        timerRef.current = setInterval(() => {
            setSeconds(s => {
                if (s <= 1) { clearInterval(timerRef.current); setCanResend(true); return 0 }
                return s - 1
            })
        }, 1000)
    }

    /* ── step 1 – send OTP ─────────────────────────────────────── */
    async function handleGetOTP() {
        const cleanMobile = mobile.replace(/\D/g, '');
        if (cleanMobile.length !== 10) {
            setShaking(true)
            setTimeout(() => setShaking(false), 500)
            return
        }

        try {
            const res = await fetch('http://localhost:3000/api/auth/send-otp', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ mobileNumber: cleanMobile })
            });
            const data = await res.json();

            if (res.ok) {
                setStep(2)
            } else {
                alert(data.error || 'Failed to send OTP');
            }
        } catch (err) {
            alert('Could not connect to the server');
        }
    }

    /* ── step 2 – OTP box input ────────────────────────────────── */
    function handleOtpChange(index, value) {
        const digit = value.replace(/\D/g, '').slice(-1)
        const newOtp = [...otp]
        newOtp[index] = digit
        setOtp(newOtp)
        if (digit && index < 5) otpRefs.current[index + 1]?.focus()
    }

    function handleOtpKeyDown(index, e) {
        if (e.key === 'Backspace' && !otp[index] && index > 0) {
            const newOtp = [...otp]
            newOtp[index - 1] = ''
            setOtp(newOtp)
            otpRefs.current[index - 1]?.focus()
        }
    }

    function handleOtpPaste(e) {
        e.preventDefault()
        const pasted = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, 6)
        const newOtp = [...otp]
        pasted.split('').forEach((ch, i) => { newOtp[i] = ch })
        setOtp(newOtp)
        otpRefs.current[Math.min(pasted.length, 5)]?.focus()
    }

    /* ── verify & login ────────────────────────────────────────── */
    async function handleVerify() {
        const fullOtp = otp.join('');
        const cleanMobile = mobile.replace(/\D/g, '');
        if (fullOtp.length !== 6) return

        try {
            const res = await fetch('http://localhost:3000/api/auth/verify-otp', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ mobileNumber: cleanMobile, otp: fullOtp })
            });
            const data = await res.json();

            if (res.ok) {
                localStorage.setItem('asha_token', data.token);
                localStorage.setItem('asha_worker', JSON.stringify(data.worker));
                navigate('/dashboard')
            } else {
                alert(data.error || 'Invalid OTP');
                setOtp(['', '', '', '', '', '']);
                otpRefs.current[0]?.focus();
            }
        } catch (err) {
            alert('Could not connect to the server');
        }
    }

    /* ── resend OTP ────────────────────────────────────────────── */
    function handleResend() {
        setOtp(['', '', '', '', '', ''])
        otpRefs.current[0]?.focus()
        startCountdown()
    }

    const otpFull = otp.every(d => d !== '')
    const pad = n => String(n).padStart(2, '0')

    return (
        <div className={styles.page}>
            {/* ── Header ─────────────────────────────────────────────── */}
            <header className={styles.header}>
                <div className={styles.headerInner}>
                    <div className={styles.brand}>
                        <div className={styles.brandLogo}>
                            <img src="/logo.jpeg" alt="ASHA Setu" className={styles.brandLogoImg} />
                        </div>
                        <div>
                            <div className={styles.brandTitle}>ASHA SETU</div>
                            <div className={styles.brandSub}>Healthcare Management Portal</div>
                        </div>
                    </div>
                    <div className={styles.headerRight}>
                        <nav className={styles.headerNav}>
                            <a href="#" className={styles.headerNavLink}>Help Desk</a>
                            <span className={styles.headerNavSep} />
                            <a href="#" className={styles.headerNavLink}>User Manual</a>
                            <span className={styles.headerNavSep} />
                            <a href="#" className={styles.headerNavLink}>About</a>
                            <span className={styles.headerNavSep} />
                            <a href="#" className={styles.headerNavLink}>Contact Us</a>
                        </nav>
                        <div className={styles.headerDivider} />
                        <div className={styles.headerPhone}>
                            <span className={styles.headerPhoneLabel}>Helpline</span>
                            <a href="tel:18001123456" className={styles.headerPhoneNum}>1800-11-2345</a>
                        </div>
                    </div>
                </div>
            </header>

            {/* ── Main ───────────────────────────────────────────────── */}
            <main className={styles.main}>
                <div className={styles.card}>

                    {/* Left panel */}
                    <div className={styles.panelLeft}>
                        <div className={styles.gridOverlay} />
                        <div className={styles.deco1} />
                        <div className={styles.deco2} />
                        <div className={styles.panelContent}>
                            <p className={styles.panelQuote}>
                                "Healthcare is not a privilege — it is a right for every village, every home."
                            </p>
                            <h1 className={styles.heroHeadline}>Empowering Our<br />Health Heroes</h1>
                            <p className={styles.heroDesc}>
                                Secure access to the Accredited Social Health Activist (ASHA) digital workspace.
                                Manage community outreach and health records efficiently.
                            </p>
                            <div className={styles.badges}>
                                <div className={styles.badge}>
                                    <svg className={styles.badgeIcon} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
                                        <polyline points="9 12 11 14 15 10" />
                                    </svg>
                                    <span>Verified Government Personnel Only</span>
                                </div>
                                <div className={styles.badge}>
                                    <svg className={styles.badgeIcon} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                                        <rect x="3" y="11" width="18" height="11" rx="2" />
                                        <path d="M7 11V7a5 5 0 0110 0v4" />
                                    </svg>
                                    <span>End-to-End Data Encryption</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* Right panel */}
                    <div className={styles.panelRight}>
                        <div className={styles.watermark} aria-hidden>
                            <svg viewBox="0 0 120 120" fill="none">
                                <rect x="10" y="50" width="100" height="65" rx="6" stroke="#E8EAF6" strokeWidth="4" />
                                <path d="M10 65h100" stroke="#E8EAF6" strokeWidth="4" />
                                <polygon points="60,5 100,35 100,50 20,50 20,35" stroke="#E8EAF6" strokeWidth="4" fill="none" />
                                <rect x="45" y="78" width="30" height="37" rx="2" stroke="#E8EAF6" strokeWidth="4" />
                            </svg>
                        </div>

                        <div className={styles.formSection}>
                            <div className={styles.formHeader}>
                                <h2 className={styles.formTitle}>Login – ASHA Management Portal</h2>
                                <p className={styles.formSubtitle}>Secure access for healthcare workers.</p>
                            </div>

                            {step === 1 ? (
                                <div key="step1" className={styles.stepWrap}>
                                    <div className={styles.fieldRow}>
                                        <label className={styles.fieldLabel} htmlFor="mobile">Registered Mobile Number</label>
                                        <span className={styles.stepBadge}>Step 1 of 2</span>
                                    </div>
                                    <div className={`${styles.phoneWrap} ${shaking ? styles.shake : ''}`}>
                                        <div className={styles.phonePrefix}>+91</div>
                                        <div className={styles.dividerV} />
                                        <input
                                            id="mobile"
                                            type="tel"
                                            className={styles.phoneInput}
                                            placeholder="00000-00000"
                                            maxLength={10}
                                            inputMode="numeric"
                                            value={mobile}
                                            onChange={e => setMobile(e.target.value.replace(/\D/g, '').slice(0, 10))}
                                            onKeyDown={e => e.key === 'Enter' && handleGetOTP()}
                                        />
                                    </div>
                                    <p className={styles.fieldHint}>Enter your registered 10-digit mobile number to receive an OTP.</p>
                                    <button className={styles.btnPrimary} onClick={handleGetOTP}>
                                        Get OTP &nbsp;→
                                    </button>
                                </div>
                            ) : (
                                <div key="step2" className={styles.stepWrap}>
                                    <div className={styles.fieldRow}>
                                        <label className={styles.fieldLabel}>Enter 6-Digit OTP</label>
                                        <span className={styles.stepBadge}>Step 2 of 2</span>
                                    </div>
                                    <div className={styles.otpBoxes} onPaste={handleOtpPaste}>
                                        {otp.map((val, i) => (
                                            <input
                                                key={i}
                                                ref={el => otpRefs.current[i] = el}
                                                className={`${styles.otpBox} ${val ? styles.otpFilled : ''}`}
                                                type="text"
                                                maxLength={1}
                                                inputMode="numeric"
                                                value={val}
                                                onChange={e => handleOtpChange(i, e.target.value)}
                                                onKeyDown={e => handleOtpKeyDown(i, e)}
                                            />
                                        ))}
                                    </div>
                                    <div className={styles.otpMeta}>
                                        <button
                                            className={styles.resendBtn}
                                            disabled={!canResend}
                                            onClick={handleResend}
                                        >Resend OTP</button>
                                        {!canResend && <span className={styles.timer}>Wait 00:{pad(seconds)}s</span>}
                                    </div>
                                    <button
                                        className={`${styles.btnPrimary} ${!otpFull ? styles.btnDisabled : ''}`}
                                        disabled={!otpFull}
                                        onClick={handleVerify}
                                    >
                                        Verify &amp; Login
                                    </button>
                                    <button className={styles.btnGhost} onClick={() => setStep(1)}>← Change Number</button>
                                </div>
                            )}

                            <div className={styles.secureNotice}>
                                <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                                    <rect x="3" y="11" width="18" height="11" rx="2" />
                                    <path d="M7 11V7a5 5 0 0110 0v4" />
                                </svg>
                                <span>THIS IS A SECURE GOVERNMENT PORTAL</span>
                            </div>
                        </div>
                    </div>
                </div>
            </main>

            {/* ── Footer ─────────────────────────────────────────────── */}
            <footer className={styles.footer}>
                <div className={styles.footerInner}>
                    <nav className={styles.footerLinks}>
                        <a href="#">Help Desk</a>
                        <a href="#">Privacy Policy</a>
                        <a href="#">Terms of Service</a>
                        <a href="#">User Manual</a>
                    </nav>
                    <span className={styles.footerCopy}>© 2026 ASHA Setu. All rights reserved.</span>
                </div>
            </footer>
        </div>
    )
}
