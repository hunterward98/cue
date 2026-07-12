// The cursive-adjacent wordmark placeholder (theming plan_1 Q2: "go the
// extra mile — we might not need to commission one"). Inline SVG so the
// self-hosted display font applies; the flourish is a hand-drawn swash,
// not a texture (content-free, per the texturing rule).
interface Props {
  // Rendered height in pixels; width follows the 5:2 viewBox.
  size?: number
}

export default function Wordmark({ size = 28 }: Props) {
  return (
    <svg
      viewBox="0 0 70 28"
      height={size}
      width={size * 2.5}
      role="img"
      aria-label="Cue"
      className="fill-ink"
    >
      <text
        x="4"
        y="19"
        fontFamily="EB Garamond Variable, Georgia, serif"
        fontStyle="italic"
        fontWeight="600"
        fontSize="22"
      >
        Cue
      </text>
      <path
        d="M6 23.5 C 20 27.5, 40 26.5, 52 22.5"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.1"
        strokeLinecap="round"
        className="text-accent"
      />
    </svg>
  )
}
