#!/usr/bin/env python3
"""Generate supabase/migrations/002_beauty_tips_catalog.sql from vg_beauty_tips_catalog.dart."""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DART = ROOT / "lib/data/vg_beauty_tips_catalog.dart"
OUT = ROOT / "supabase/migrations/002_beauty_tips_catalog.sql"

GLOBAL_DISCLAIMER = (
    "Verified Glam does not provide medical diagnosis or treatment. "
    "Tips reflect community experiences only. Consult a licensed professional for skin conditions, "
    "allergies, or persistent concerns. Patch-test new products and discontinue use if irritation occurs."
)


def sql_str(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"


def parse_categories(text: str) -> list[dict]:
    blocks = re.findall(
        r"VGBeautyCategoryDef\(\s*"
        r"id: '([^']+)',\s*"
        r"name: '([^']+)',\s*"
        r"shortLabel: '([^']+)',\s*"
        r"color: (0x[0-9A-Fa-f]+),\s*"
        r"anchorX: ([\d.]+),\s*"
        r"anchorY: ([\d.]+),\s*"
        r"labelSide: '([^']+)',\s*"
        r"issueTags: \[([^\]]*)\]",
        text,
        re.DOTALL,
    )
    cats = []
    for i, b in enumerate(blocks):
        tags_raw = b[7]
        tags = re.findall(r"'([^']*)'", tags_raw)
        cats.append(
            {
                "id": b[0],
                "name": b[1],
                "short_label": b[2],
                "color": int(b[3], 16),
                "anchor_x": b[4],
                "anchor_y": b[5],
                "label_side": b[6],
                "issue_tags": tags,
                "sort_order": i + 1,
            }
        )
    return cats


def parse_spot_labels(text: str) -> list[tuple[str, str]]:
    m = re.search(r"_spotLabelFromTag = <String, String>\{([^}]+)\}", text, re.DOTALL)
    if not m:
        return []
    pairs = re.findall(r"'([^']+)': '([^']+)'", m.group(1))
    return pairs


def parse_tips(text: str) -> list[dict]:
    tips = []
    cat_blocks = re.split(r"\n    '(\w+)': \{\n", text)
    # first chunk is before first category
    for i in range(1, len(cat_blocks), 2):
        cat_id = cat_blocks[i]
        body = cat_blocks[i + 1]
        for sev in ("high", "medium", "low"):
            sev_match = re.search(rf"'{sev}': \[([\s\S]*?)\n      \],", body)
            if not sev_match:
                continue
            entries = re.findall(
                r"VGBeautyTipEntry\(\s*title: '([^']*(?:\\'[^']*)*)',\s*body:\s*'([^']*(?:\\'[^']*)*)',?\s*\)",
                sev_match.group(1),
                re.DOTALL,
            )
            for j, (title, body_text) in enumerate(entries):
                title = title.replace("\\'", "'")
                body_text = body_text.replace("\\'", "'").replace("\n              ", " ").strip()
                tips.append(
                    {
                        "category_id": cat_id,
                        "severity": sev,
                        "title": title,
                        "body": body_text,
                        "sort_order": j + 1,
                    }
                )
    return tips


def main() -> None:
    text = DART.read_text(encoding="utf-8")
    categories = parse_categories(text)
    spot_labels = parse_spot_labels(text)
    tips = parse_tips(text)

    lines: list[str] = [
        "-- Beauty tips catalog — seeded from lib/data/vg_beauty_tips_catalog.dart",
        "",
        "create table if not exists public.beauty_tip_categories (",
        "  id text primary key,",
        "  name text not null,",
        "  short_label text not null,",
        "  color bigint not null,",
        "  anchor_x double precision not null,",
        "  anchor_y double precision not null,",
        "  label_side text not null,",
        "  issue_tags jsonb not null default '[]'::jsonb,",
        "  sort_order int not null default 0",
        ");",
        "",
        "create table if not exists public.beauty_tip_entries (",
        "  id uuid primary key default gen_random_uuid(),",
        "  category_id text not null references public.beauty_tip_categories (id) on delete cascade,",
        "  severity text not null check (severity in ('high', 'medium', 'low')),",
        "  title text not null,",
        "  body text not null,",
        "  sort_order int not null default 0",
        ");",
        "",
        "create index if not exists beauty_tip_entries_cat_sev_idx",
        "  on public.beauty_tip_entries (category_id, severity, sort_order);",
        "",
        "create table if not exists public.beauty_spot_label_map (",
        "  id uuid primary key default gen_random_uuid(),",
        "  issue_tag text not null unique,",
        "  display_label text not null",
        ");",
        "",
        "create table if not exists public.app_content (",
        "  key text primary key,",
        "  value text not null",
        ");",
        "",
        "alter table public.beauty_tip_categories enable row level security;",
        "alter table public.beauty_tip_entries enable row level security;",
        "alter table public.beauty_spot_label_map enable row level security;",
        "alter table public.app_content enable row level security;",
        "",
        "create policy beauty_tip_categories_select on public.beauty_tip_categories",
        "  for select to authenticated using (true);",
        "create policy beauty_tip_entries_select on public.beauty_tip_entries",
        "  for select to authenticated using (true);",
        "create policy beauty_spot_label_map_select on public.beauty_spot_label_map",
        "  for select to authenticated using (true);",
        "create policy app_content_select on public.app_content",
        "  for select to authenticated using (true);",
        "",
        "insert into public.app_content (key, value) values",
        f"  ('beauty_tips_global_disclaimer', {sql_str(GLOBAL_DISCLAIMER)})",
        "on conflict (key) do update set value = excluded.value;",
        "",
    ]

    for c in categories:
        tags_json = sql_str(json.dumps(c["issue_tags"])) + "::jsonb"
        lines.append(
            "insert into public.beauty_tip_categories "
            "(id, name, short_label, color, anchor_x, anchor_y, label_side, issue_tags, sort_order) values "
            f"({sql_str(c['id'])}, {sql_str(c['name'])}, {sql_str(c['short_label'])}, "
            f"{c['color']}, {c['anchor_x']}, {c['anchor_y']}, {sql_str(c['label_side'])}, "
            f"{tags_json}, {c['sort_order']}) "
            "on conflict (id) do update set "
            "name = excluded.name, short_label = excluded.short_label, color = excluded.color, "
            "anchor_x = excluded.anchor_x, anchor_y = excluded.anchor_y, label_side = excluded.label_side, "
            "issue_tags = excluded.issue_tags, sort_order = excluded.sort_order;"
        )

    lines.append("")
    for tag, label in spot_labels:
        lines.append(
            "insert into public.beauty_spot_label_map (issue_tag, display_label) values "
            f"({sql_str(tag.lower())}, {sql_str(label)}) "
            "on conflict (issue_tag) do update set display_label = excluded.display_label;"
        )

    lines.append("")
    for t in tips:
        lines.append(
            "insert into public.beauty_tip_entries (category_id, severity, title, body, sort_order) values "
            f"({sql_str(t['category_id'])}, {sql_str(t['severity'])}, {sql_str(t['title'])}, "
            f"{sql_str(t['body'])}, {t['sort_order']});"
        )

    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {OUT} ({len(categories)} categories, {len(tips)} tips, {len(spot_labels)} labels)")


if __name__ == "__main__":
    main()
