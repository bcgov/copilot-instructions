# Copilot Instructions Repository - Specific Guidance

This repository manages shared BCGov AI coding instructions. Repository-specific practices:

## Repository Context
This is a template/standards repository that distributes `copilot-upstream.md` to all BCGov development teams. Changes here affect hundreds of developers.

## Distribution Model
- **ONLY** `.github/copilot-upstream.md` is distributed via curl to downstream PCs
- Other files in this repo are for documentation and automation only
- Any instruction content must go in `copilot-upstream.md` or it won't reach developers

## Content Management
- Universal coding standards → `copilot-upstream.md`
- Repository documentation → `README.md`
- Automation workflows → `.github/workflows/`

## Standards Evolution
- Keep `copilot-upstream.md` focused on universal principles
- Add examples and onboarding guidance to `README.md`
- Use GitHub Actions to enforce consistency across BCGov repos
- Regular review to prevent instruction bloat and maintain effectiveness

## Copilot Configuration
This repository uses `.github/copilot-upstream.md` as the primary instruction source for AI coding assistance.

## Remember
Changes to `copilot-upstream.md` impact all BCGov developers - prioritize clarity, safety, and universal applicability.
